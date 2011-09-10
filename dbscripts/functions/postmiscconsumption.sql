CREATE OR REPLACE FUNCTION postMiscConsumption(INTEGER, NUMERIC, INTEGER, INTEGER, INTEGER, NUMERIC, TEXT, TEXT) RETURNS NUMERIC AS $$
DECLARE
  pItemsiteid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  pParentItemid ALIAS FOR $3;
  pWIPAccntid ALIAS FOR $4;
  pItemlocSeries ALIAS FOR $5;
  pCarryCost ALIAS FOR $6;
  pDocNumber ALIAS FOR $7;
  pComments ALIAS FOR $8;
  _cost NUMERIC;
  _r RECORD;

BEGIN

  IF ( ( SELECT (item_type = 'F')
         FROM itemsite, item
         WHERE ( (itemsite_item_id=item_id)
          AND (itemsite_id=pItemsiteid) ) ) ) THEN

    _cost := 0;

    FOR _r IN SELECT cs.itemsite_id AS c_itemsite_id,
                     roundQty(itemuomfractionalbyuom(bomitem_item_id, bomitem_uom_id),
                              itemuomtouom(bomitem_item_id, bomitem_uom_id, NULL, (bomitem_qtyfxd + bomitem_qtyper * pQty) * (1 + bomitem_scrap))) AS qty
              FROM itemsite AS cs, itemsite AS ps, item, bomitem
              WHERE ( (cs.itemsite_item_id=item_id)
               AND (cs.itemsite_warehous_id=ps.itemsite_warehous_id)
               AND (bomitem_parent_item_id=ps.itemsite_item_id)
               AND (bomitem_item_id=cs.itemsite_item_id)
               AND (bomitem_rev_id=getActiveRevId('BOM',bomitem_parent_item_id))
               AND (ps.itemsite_id=pItemsiteid) 
               AND (CURRENT_DATE BETWEEN bomitem_effective AND bomitem_expires)
               AND (item_type NOT IN ('R','T')) )
              ORDER BY bomitem_seqnumber LOOP

      SELECT postMiscConsumption( _r.c_itemsite_id, _r.qty, pParentItemid,
                                  pWIPAccntid, pItemlocSeries, _cost, pDocNumber, pComments ) INTO _cost;

    END LOOP;
  ELSE
    PERFORM postInvTrans( itemsite_id, 'IM', pQty,
                          'W/O', 'WO', 'Misc.', pDocNumber,
                          ('Consumed during Misc. Production of Item Number ' || item_number || '
                          ' || pComments),
                          pWIPAccntid, costcat_asset_accnt_id, pItemlocSeries )
    FROM itemsite, costcat, item
    WHERE ( (itemsite_costcat_id=costcat_id)
     AND (itemsite_id=pItemsiteid)
     AND (item_id=pParentItemid) );

    SELECT (pCarryCost + (stdcost(itemsite_item_id) * pQty)) INTO _cost
    FROM itemsite
    WHERE (itemsite_id=pItemsiteid);
  END IF;

  RETURN _cost;

END;
$$ LANGUAGE 'plpgsql';
