CREATE OR REPLACE FUNCTION returnShipmentTransaction(INTEGER) RETURNS INTEGER AS $$
BEGIN
  RETURN returnShipmentTransaction($1, 0, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION returnShipmentTransaction(INTEGER, INTEGER) RETURNS INTEGER AS $$
BEGIN
  RETURN returnShipmentTransaction($1, $2, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION returnShipmentTransaction(INTEGER, INTEGER, TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
DECLARE
  pshipitemid		ALIAS FOR $1;
  _itemlocSeries	INTEGER			 := $2;
  _timestamp		TIMESTAMP WITH TIME ZONE := $3;
  _invhistid INTEGER;
  _itemlocrsrvid INTEGER;
  _coheadid INTEGER;
  _rows INTEGER;
  _r RECORD;
  _rsrv RECORD;

BEGIN

    IF (COALESCE(_itemlocSeries,0) = 0 ) THEN
      _itemlocSeries := NEXTVAL('itemloc_series_seq');
    END IF;
  
    -- Find the shipment transaction record
    SELECT shipitem_id, shipitem_qty, shipitem_invhist_id, shipitem_value,
      shipitem_orderitem_id, invhist_series,
      shiphead_id, shiphead_order_type,
      itemsite_loccntrl, itemsite_costmethod, itemsite_controlmethod,
      cohead_prj_id AS prj_id     
      INTO _r
    FROM shipitem
      JOIN shiphead ON (shiphead_id=shipitem_shiphead_id)
      JOIN invhist ON (invhist_id=shipitem_invhist_id)
      JOIN itemsite ON (itemsite_id=invhist_itemsite_id)
      LEFT OUTER JOIN cohead ON ((shiphead_order_type = 'SO')
                      AND (shiphead_order_id = cohead_id))
    WHERE ((NOT shiphead_shipped)
      AND  (shipitem_id=pshipitemid));
      
    GET DIAGNOSTICS _rows = ROW_COUNT;
    IF (_rows = 0 ) THEN
      -- Was it a non-controlled sales order item?
      SELECT shipitem_id, shipitem_qty, shipitem_orderitem_id,
        shiphead_id, shiphead_order_type, shipitem_value, shipitem_invhist_id,
        itemsite_loccntrl, itemsite_costmethod, itemsite_controlmethod,
        cohead_prj_id AS prj_id
      INTO _r
      FROM shipitem
        JOIN shiphead ON (shiphead_id=shipitem_shiphead_id)
        JOIN coitem ON (shipitem_orderitem_id=coitem_id)
        JOIN cohead ON (cohead_id=coitem_cohead_id)
        JOIN itemsite ON (itemsite_id=coitem_itemsite_id)
      WHERE ((NOT shiphead_shipped)
        AND  (shipitem_id=pshipitemid)
        AND (shiphead_order_type = 'SO'));
    END IF;
    
    GET DIAGNOSTICS _rows = ROW_COUNT;
    IF (_rows = 0 AND fetchmetricbool('MultiWhs') ) THEN
      -- Was it a non-controlled transfer order item?
      SELECT shipitem_id, shipitem_qty, shipitem_orderitem_id,
        shiphead_id, shiphead_order_type, shipitem_value, shipitem_invhist_id,
        itemsite_loccntrl, itemsite_costmethod, itemsite_controlmethod,
        NULL AS prj_id
      INTO _r
      FROM shipitem
        JOIN shiphead ON (shiphead_id=shipitem_shiphead_id)
        JOIN toitem ON (shipitem_orderitem_id=toitem_id)
        JOIN itemsite ON (itemsite_id=coitem_itemsite_id)
      WHERE ((NOT shiphead_shipped)
        AND  (shipitem_id=pshipitemid)
        AND (shiphead_order_type = 'TO'));
    END IF;
    
    IF (_rows > 0 ) THEN  
      IF (_r.shiphead_order_type = 'SO') THEN
        -- Handle inventory transaction
        IF (_r.itemsite_controlmethod != 'N' OR _r.itemsite_costmethod = 'J') THEN
          SELECT postInvTrans( itemsite_id, 'RS', _r.shipitem_qty * coitem_qty_invuomratio,
          		  'S/R', _r.shiphead_order_type, formatSoNumber(_r.shipitem_orderitem_id),
			  shiphead_number, 'Return from Shipping',
			  costcat_asset_accnt_id, getPrjAccntId(_r.prj_id, costcat_shipasset_accnt_id),
			  _itemlocSeries, _timestamp, _r.shipitem_value, _r.shipitem_invhist_id ) INTO _invhistid
          FROM coitem, itemsite, costcat, shiphead, shipitem
          WHERE ( (coitem_itemsite_id=itemsite_id)
           AND (itemsite_costcat_id=costcat_id)
           AND (coitem_id=_r.shipitem_orderitem_id)
           AND (shiphead_order_type=_r.shiphead_order_type)
           AND (shiphead_id=shipitem_shiphead_id)
           AND (shipitem_orderitem_id=_r.shipitem_orderitem_id) );   
 
          -- We know the distribution so post this through so the any w/o activity knows about it
          PERFORM postItemlocseries(_itemlocSeries);
        END IF;
 
        IF (_r.itemsite_costmethod = 'J') THEN   
          -- Reopen the work order
          UPDATE wo SET wo_status = 'I' WHERE ((wo_ordtype='S') AND (wo_ordid=_r.shipitem_orderitem_id));
          
          --  Job cost, so correct Production Posting referencing original receipt for reverse info.
          PERFORM correctProduction(wo_id, invhist_invqty, false, _itemlocSeries, _timestamp, invhist_id)
          FROM wo, invhist
          WHERE ((wo_ordtype = 'S')
             AND (wo_ordid = _r.shipitem_orderitem_id) 
             AND (invhist_series=_r.invhist_series)
             AND (invhist_transtype='RM'));
             
          --  Return eligble material
          PERFORM returnWoMaterial(womatlpost_womatl_id, _itemlocSeries, _timestamp, womatlpost_invhist_id)
          FROM womatlpost, invhist m, invhist s 
          WHERE ((womatlpost_invhist_id=m.invhist_id)
           AND (m.invhist_series=s.invhist_series)
           AND (m.invhist_transtype='IM')
           AND (s.invhist_id=_r.shipitem_invhist_id));

        END IF;

      ELSIF (_r.shiphead_order_type = 'TO') THEN
        SELECT postInvTrans( itemsite_id, 'RS', _r.shipitem_qty,
			  'S/R', _r.shiphead_order_type, formatToNumber(toitem_id),
			  tohead_number, 'Return from Shipping',
			  costcat_asset_accnt_id, costcat_shipasset_accnt_id,
			  _itemlocSeries, _timestamp, _r.shipitem_value, _r.shipitem_invhist_id ) INTO _invhistid
        FROM toitem, tohead, itemsite, costcat
        WHERE ((toitem_item_id=itemsite_item_id)
          AND  (toitem_tohead_id=tohead_id)
  	  AND  (tohead_src_warehous_id=itemsite_warehous_id)
          AND  (itemsite_costcat_id=costcat_id)
          AND  (toitem_id=_r.shipitem_orderitem_id) );

      ELSE
        -- Don't know what kind of order this is
        RETURN -11;
      END IF;

      UPDATE shiphead
      SET shiphead_sfstatus='D'
      WHERE ((shiphead_id=_r.shiphead_id)
        AND  (shiphead_sfstatus='P'));

       -- Handle reservation if applicable
      IF (fetchmetricbool('EnableSOReservations')) THEN
        UPDATE coitem
          SET coitem_qtyreserved = coitem_qtyreserved + shipitemrsrv_qty
        FROM shipitemrsrv
        WHERE ((coitem_id=_r.shipitem_orderitem_id)
        AND (shipitemrsrv_shipitem_id=_r.shipitem_id));

        -- Handle location reservations if applicable
        FOR _rsrv IN
          SELECT *
          FROM shipitemlocrsrv
          WHERE (shipitemlocrsrv_shipitem_id=_r.shipitem_id)
        LOOP
          -- See if a reservation record still exists
          SELECT itemlocrsrv_id, itemlocrsrv_qty INTO _itemlocrsrvid
          FROM itemlocrsrv
            JOIN itemloc ON (itemlocrsrv_itemloc_id=itemloc_id)
          WHERE ((itemlocrsrv_source = 'SO')
            AND (itemlocrsrv_source_id = _r.shipitem_orderitem_id )
            AND (itemloc_itemsite_id=_rsrv.shipitemlocrsrv_itemsite_id)
            AND (itemloc_location_id=_rsrv.shipitemlocrsrv_location_id)
            AND (COALESCE(itemloc_ls_id, -1)=COALESCE(_rsrv.shipitemlocrsrv_ls_id, -1))
            AND (COALESCE(itemloc_expiration,endOfTime())=COALESCE(_rsrv.shipitemlocrsrv_expiration,endOfTime()))
            AND (COALESCE(itemloc_warrpurc,endoftime())=COALESCE(_rsrv.shipitemlocrsrv_warrpurc,endoftime())) );

          GET DIAGNOSTICS _rows = ROW_COUNT;
          IF (_rows > 0 ) THEN  
            -- Update existing
            UPDATE itemlocrsrv
            SET itemlocrsrv_qty = itemlocrsrv_qty + _rsrv.shipitemlocrsrv_qty
            WHERE (itemlocrsrv_id=_itemlocrsvrid);
          ELSE
            -- Recreate record
            INSERT INTO itemlocrsrv
            SELECT nextval('itemlocrsrv_itemlocrsrv_id_seq'), 'SO', _r.shipitem_orderitem_id,
              itemloc_id, _rsrv.shipitemlocrsrv_qty
            FROM itemloc
            WHERE ((itemloc_itemsite_id=_rsrv.shipitemlocrsrv_itemsite_id)
              AND (itemloc_location_id=_rsrv.shipitemlocrsrv_location_id)
              AND (COALESCE(itemloc_ls_id, -1)=COALESCE(_rsrv.shipitemlocrsrv_ls_id, -1))
              AND (COALESCE(itemloc_expiration,endOfTime())=COALESCE(_rsrv.shipitemlocrsrv_expiration,endOfTime()))
              AND (COALESCE(itemloc_warrpurc,endoftime())=COALESCE(_rsrv.shipitemlocrsrv_warrpurc,endoftime())) );
          END IF;
        END LOOP;
      END IF;
      
      DELETE FROM shipitem WHERE (shipitem_id = _r.shipitem_id );
    END IF;

    RETURN _itemlocSeries;

END;
$$ LANGUAGE 'plpgsql';
