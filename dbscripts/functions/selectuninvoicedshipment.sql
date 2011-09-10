CREATE OR REPLACE FUNCTION selectuninvoicedshipment(integer)
  RETURNS integer AS
$BODY$
DECLARE
  pCosmiscid ALIAS FOR $1;
  _cobmiscid INTEGER;
  _r RECORD;
  _cobillid INTEGER;
  _taxtypeid INTEGER := NULL;

BEGIN

--  Grab all of the uninvoiced coship records
  FOR _r IN SELECT cohead_id, coitem_id, SUM(coship_qty) AS qty,
                   coitem_price, coitem_price_invuomratio AS invpricerat, coitem_qty_invuomratio, item_id,
                   ( ((coitem_qtyord - coitem_qtyshipped + coitem_qtyreturned) <= 0)
                    OR (NOT cust_partialship) ) AS toclose, coitem_taxtype_id
            FROM cosmisc, coship, coitem, cohead, custinfo, itemsite, item
            WHERE ( (coship_cosmisc_id=cosmisc_id)
             AND (coship_coitem_id=coitem_id)
             AND (coitem_cohead_id=cohead_id)
             AND (cosmisc_shipped)
             AND (NOT coship_invoiced)
             AND (coitem_itemsite_id=itemsite_id)
             AND (itemsite_item_id=item_id)
             AND (cohead_cust_id=cust_id)
             AND (item_type != 'K')
             AND (cosmisc_id=pCosmiscid) )
            GROUP BY cohead_id, coitem_id, cust_partialship, coitem_taxtype_id,
                     coitem_qtyord, coitem_qtyshipped, coitem_qtyreturned,
                     coitem_price, invpricerat, coitem_qty_invuomratio, item_id
            UNION
            SELECT cohead_id, coitem_id, coitem_qtyord AS qty,
                   coitem_price, coitem_price_invuomratio AS invpricerat, coitem_qty_invuomratio, item_id,
                   true AS toclose, coitem_taxtype_id
              FROM cosmisc, cohead, custinfo, itemsite, item, coitem AS kit
             WHERE((cosmisc_cohead_id=cohead_id)
               AND (coitem_cohead_id=cohead_id)
               AND (coitem_status='O')
               AND (cosmisc_shipped)
               AND (coitem_itemsite_id=itemsite_id)
               AND (itemsite_item_id=item_id)
               AND (cohead_cust_id=cust_id)
               AND (item_type = 'K')
               AND (cosmisc_id=pCosmiscid)
               AND (coitem_linenumber NOT IN  
                      (SELECT sub.coitem_linenumber
                       FROM coitem AS sub 
                       WHERE sub.coitem_cohead_id=kit.coitem_cohead_id
                        AND sub.coitem_linenumber=kit.coitem_linenumber 
                        AND sub.coitem_subnumber > 0 
                        AND ((sub.coitem_qtyord - sub.coitem_qtyshipped + sub.coitem_qtyreturned) > 0)
                        LIMIT 1)
               ))
             GROUP BY cohead_id, coitem_id, cust_partialship, coitem_taxtype_id,
                      coitem_qtyord, coitem_qtyshipped, coitem_qtyreturned,
                      coitem_price, invpricerat, coitem_qty_invuomratio, item_id, coitem_linenumber LOOP

--  Check to see if a cobmisc head exists for this cohead
    SELECT createBillingHeader(_r.cohead_id) INTO _cobmiscid;

    SELECT cobill_id INTO _cobillid
      FROM cobill, cobmisc, coitem
     WHERE ((cobill_cobmisc_id=cobmisc_id)
       AND  (cobmisc_cohead_id=coitem_cohead_id)
       AND  (cobill_coitem_id=coitem_id)
       AND  (NOT cobmisc_posted)
       AND  (cobill_cobmisc_id=_cobmiscid)
       AND  (coitem_id=_r.coitem_id))
     LIMIT 1;
     
    IF (FOUND) THEN
      UPDATE cobill
         SET cobill_selectdate = CURRENT_DATE,
             cobill_select_username = getEffectiveXtUser(),
             cobill_qty = cobill_qty + _r.qty,
             cobill_toclose = _r.toclose,
             cobill_taxtype_id = _r.coitem_taxtype_id
      WHERE (cobill_id=_cobillid);
    ELSE
--  Now insert the cobill line
      INSERT INTO cobill
      ( cobill_cobmisc_id, cobill_coitem_id,
        cobill_selectdate, cobill_select_username,
        cobill_qty, cobill_toclose,
        cobill_taxtype_id )
      VALUES
      ( _cobmiscid, _r.coitem_id,
        CURRENT_DATE, getEffectiveXtUser(),
        _r.qty, _r.toclose,
         _r.coitem_taxtype_id );
     END IF;      

  END LOOP;

  RETURN _cobmiscid;

END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;