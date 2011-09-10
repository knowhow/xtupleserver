CREATE OR REPLACE FUNCTION distributeToLocations(INTEGER) RETURNS INTEGER AS $$
DECLARE
  pItemlocdistid ALIAS FOR $1;
  _distCounter INTEGER;
  _itemlocdist RECORD;
  _itemlocid INTEGER;
  _runningQty NUMERIC;
  _tmp RECORD;

BEGIN

  _distCounter := 0;
  _runningQty  := 0;

-- A scenario can occur where two people try to post distributions
-- to the same itemsite against two or more lot/serial/mlc locations
-- leading to a deadlock. This line tries to prevent that by locking
-- ahead of time all the itemsites that the transaction will need
-- before any of the other tables are locked individually.
  SELECT itemsite_id
    INTO _tmp
    FROM itemsite
   WHERE(itemsite_id in (SELECT DISTINCT itemlocdist_itemsite_id
                           FROM itemlocdist
                          WHERE(itemlocdist_id=pItemlocdistid)))
     FOR UPDATE;

--  March through all of the itemlocdist owned by the passed parent itemlocdist
  FOR _itemlocdist IN SELECT c.itemlocdist_id AS itemlocdistid,
                             c.itemlocdist_source_type AS type,
                             c.itemlocdist_source_id AS sourceid,
                             c.itemlocdist_qty AS qty,
                             p.itemlocdist_itemsite_id AS itemsiteid,
                             itemsite_freeze,
                             p.itemlocdist_invhist_id AS invhistid,
                             p.itemlocdist_ls_id AS lotserialid,
                             p.itemlocdist_expiration AS expiration,
                             p.itemlocdist_warranty AS warranty,
                             p.itemlocdist_order_type AS ordertype,
                             p.itemlocdist_order_id AS orderid,
                             p.itemlocdist_series AS series
                      FROM itemlocdist AS c, itemlocdist AS p, itemsite
                      WHERE ( (c.itemlocdist_itemlocdist_id=p.itemlocdist_id)
                       AND (p.itemlocdist_source_type='O')
                       AND (p.itemlocdist_itemsite_id=itemsite_id)
                       AND (p.itemlocdist_id=pItemlocdistid) ) LOOP

    _distCounter := _distCounter + 1;

--  If the target for this itemlocdist is a location, check to see if the
--  required itemloc already exists
    IF (_itemlocdist.type = 'L') THEN
      SELECT itemloc_id INTO _itemlocid
      FROM itemloc
      WHERE ( (itemloc_itemsite_id=_itemlocdist.itemsiteid)
       AND (itemloc_location_id=_itemlocdist.sourceid)
       AND (COALESCE(itemloc_ls_id, -1)=COALESCE(_itemlocdist.lotserialid, -1))
       AND (COALESCE(itemloc_expiration,endOfTime())=COALESCE(_itemlocdist.expiration,endOfTime()))
       AND (COALESCE(itemloc_warrpurc,endoftime())=COALESCE(_itemlocdist.warranty,endoftime())) );

--  Nope, make it
      IF (NOT FOUND) THEN
        SELECT NEXTVAL('itemloc_itemloc_id_seq') INTO _itemlocid;
        INSERT INTO itemloc
        ( itemloc_id, itemloc_itemsite_id,
          itemloc_location_id, itemloc_qty,
          itemloc_ls_id, itemloc_expiration,
          itemloc_warrpurc )
        VALUES
        ( _itemlocid, _itemlocdist.itemsiteid,
          _itemlocdist.sourceid, 0,
          _itemlocdist.lotserialid, _itemlocdist.expiration,
          _itemlocdist.warranty );
      END IF;

    ELSE
--  Yep, cache it
      _itemlocid = _itemlocdist.sourceid;

      IF (_itemlocid IS NOT NULL AND (SELECT count(itemloc_id) = 0 FROM itemloc WHERE itemloc_id=_itemlocid)) THEN
        RAISE EXCEPTION 'No record to distribute against. Someone else may have already distributed this record.';
      END IF;
    END IF;

--  Record the invdetail for this itemlocdist
    INSERT INTO invdetail
    ( invdetail_invhist_id, invdetail_location_id, invdetail_ls_id,
      invdetail_qty, invdetail_qty_before, invdetail_qty_after, invdetail_expiration, 
      invdetail_warrpurc )
    SELECT _itemlocdist.invhistid, itemloc_location_id, itemloc_ls_id,
           _itemlocdist.qty, itemloc_qty, (itemloc_qty + _itemlocdist.qty),
           itemloc_expiration,_itemlocdist.warranty
    FROM itemloc
    WHERE (itemloc_id=_itemlocid);

--  Update the parent invhist to indicate that it has invdetail records
    UPDATE invhist
    SET invhist_hasdetail=TRUE
    WHERE ((invhist_hasdetail=FALSE)
     AND (invhist_id=_itemlocdist.invhistid));

--  Update the itemloc_qty if its parent itemsite is not frozen
    IF (NOT _itemlocdist.itemsite_freeze) THEN
      UPDATE itemloc
      SET itemloc_qty = (itemloc_qty + _itemlocdist.qty)
      WHERE (itemloc_id=_itemlocid);

      PERFORM postInvHist(_itemlocdist.invhistid);

--  Handle reservation data
      IF ( (SELECT fetchMetricBool('EnableSOReservationsByLocation')) AND
           (_itemlocdist.qty < 0) ) THEN

--  If a shipment on a sales order, record reservation change before updating
--  so it can be reversed later if necessary
        IF (_itemlocdist.ordertype = 'SO') THEN
          INSERT INTO shipitemlocrsrv
          SELECT nextval('shipitemlocrsrv_shipitemlocrsrv_id_seq'),
            shipitem_id, itemloc_itemsite_id, itemloc_location_id,
            itemloc_ls_id, itemloc_expiration, itemloc_warrpurc,
            least(_itemlocdist.qty, itemlocrsrv_qty)
          FROM shipitem, itemloc
            JOIN itemlocrsrv ON (itemloc_id=itemlocrsrv_itemloc_id)
          WHERE ( (shipitem_invhist_id=_itemlocdist.invhistid)
            AND   (itemloc_id=_itemlocid)
            AND   (itemlocrsrv_source=_itemlocdist.ordertype)
            AND   (itemlocrsrv_source_id=_itemlocdist.orderid) );
        END IF;

--  Update the itemloc reservation
        UPDATE itemlocrsrv
        SET itemlocrsrv_qty = (itemlocrsrv_qty + _itemlocdist.qty)
        WHERE ( (itemlocrsrv_itemloc_id=_itemlocid)
          AND   (itemlocrsrv_source=_itemlocdist.ordertype)
          AND   (itemlocrsrv_source_id=_itemlocdist.orderid) );
          
--  Delete reservation if fully distributed
        DELETE FROM itemlocrsrv
        WHERE ( (itemlocrsrv_itemloc_id=_itemlocid)
          AND   (itemlocrsrv_source=_itemlocdist.ordertype)
          AND   (itemlocrsrv_source_id=_itemlocdist.orderid)
          AND   (itemlocrsrv_qty=0) );
      END IF;
    END IF;

--  Adjust QOH if this itemlocdist is to/from a non-netable location
    IF ( SELECT (NOT location_netable)
         FROM itemloc, location
         WHERE ((itemloc_location_id=location_id)
          AND (itemloc_id=_itemlocid)) ) THEN

--  Record the invhist record for the netable->non-netable (or visaversa)
      INSERT INTO invhist
      ( invhist_itemsite_id,
        invhist_transtype, invhist_invqty,
        invhist_qoh_before, invhist_qoh_after,
        invhist_docnumber, invhist_comments,
        invhist_invuom, invhist_unitcost,
        invhist_costmethod, invhist_value_before, invhist_value_after,
        invhist_series )
      SELECT itemsite_id,
             'NN', (_itemlocdist.qty * -1),
             itemsite_qtyonhand, (itemsite_qtyonhand - _itemlocdist.qty),
             invhist_docnumber, invhist_comments,
             uom_name, stdCost(item_id),
             itemsite_costmethod, itemsite_value,
             (itemsite_value + (_itemlocdist.qty * -1 * CASE WHEN(itemsite_costmethod='A') THEN avgcost(itemsite_id)
                                                             ELSE stdCost(itemsite_item_id)
                                                        END)),
             _itemlocdist.series
      FROM item, itemsite, invhist, uom
      WHERE ( (itemsite_item_id=item_id)
       AND (item_inv_uom_id=uom_id)
       AND (itemsite_controlmethod <> 'N')
       AND (itemsite_id=_itemlocdist.itemsiteid)
       AND (invhist_id=_itemlocdist.invhistid) );

--  Update the itemsite_qoh
      IF (NOT _itemlocdist.itemsite_freeze) THEN
        UPDATE itemsite
        SET itemsite_qtyonhand = (itemsite_qtyonhand - _itemlocdist.qty),
            itemsite_nnqoh = (itemsite_nnqoh + _itemlocdist.qty)
        FROM itemloc
        WHERE ((itemloc_itemsite_id=itemsite_id)
         AND (itemloc_id=_itemlocid));
      END IF;
    END IF;

--  Cache the running qty.
    _runningQty := _runningQty + _itemlocdist.qty;

--  Dene with the child itemlocdist, so delete it
    DELETE FROM itemlocdist
    WHERE (itemlocdist_id=_itemlocdist.itemlocdistid);

--  If the target itemloc is now at qty=0, delete it if its parent
--  itemsite is not frozen
    IF (NOT _itemlocdist.itemsite_freeze) THEN
      DELETE FROM itemloc
      WHERE ( (itemloc_qty=0)
       AND (itemloc_id=_itemlocid) );
    END IF;

  END LOOP;

--  If the running qty for the detailed distributions is the same as the
--  total qty to distribute indicated by the parent itemlocdist, then the
--  parent itemlocdist has been fully distributed and should be deleted.
  IF ( ( SELECT itemlocdist_qty
         FROM itemlocdist
         WHERE (itemlocdist_id=pItemlocdistid) ) = _runningQty) THEN
    DELETE FROM itemlocdist
    WHERE (itemlocdist_id=pItemlocdistid);
  ELSE
--  There is still some more qty to distribute in the parent itemlocdist.
--  Update the qty to distribute with the qty that has been distributed.
    UPDATE itemlocdist
    SET itemlocdist_qty = (itemlocdist_qty - _runningQty)
    WHERE (itemlocdist_id=pItemlocdistid);
  END IF;

  RETURN _distCounter;

END;
$$ LANGUAGE 'plpgsql';
