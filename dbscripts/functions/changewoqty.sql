CREATE OR REPLACE FUNCTION changeWoQty(INTEGER, NUMERIC, BOOLEAN) RETURNS INTEGER AS $$
DECLARE
  pWoid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  changeChildren ALIAS FOR $3;
  _r RECORD;
  _result INTEGER := 1;

BEGIN

  SELECT wo_qtyord, wo_status, item_fractional INTO _r
  FROM wo JOIN itemsite ON (itemsite_id=wo_itemsite_id)
          JOIN item ON (item_id=itemsite_item_id)
  WHERE (wo_id=pWoid);

  IF (_r.wo_qtyord = pQty) THEN
    RETURN 0;
  END IF;

  IF (NOT _r.wo_status IN ('O','E','R','I')) THEN
    RETURN 1;
  END IF;

  IF (_r.wo_status IN ('R','I')) THEN
    INSERT INTO evntlog (evntlog_evnttime, evntlog_username, evntlog_evnttype_id,
                         evntlog_ordtype, evntlog_ord_id, evntlog_warehous_id, evntlog_number,
                         evntlog_oldvalue, evntlog_newvalue)
    SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,
           'W', wo_id, itemsite_warehous_id, formatWoNumber(wo_id),
           wo_qtyord, pQty
    FROM evntnot, evnttype, itemsite, item, wo
    WHERE ( (evntnot_evnttype_id=evnttype_id)
     AND (evntnot_warehous_id=itemsite_warehous_id)
     AND (wo_itemsite_id=itemsite_id)
     AND (itemsite_item_id=item_id)
     AND (evnttype_name='RWoQtyRequestChange')
     AND (wo_id=pWoid) );

     _result = 0;
  END IF;

  UPDATE wo
  SET wo_qtyord=roundQty(_r.item_fractional, pQty)
  WHERE (wo_id=pWoid);

  UPDATE womatl
  SET womatl_qtyreq=(womatl_qtyfxd + wo_qtyord * womatl_qtyper) * (1 + womatl_scrap)
  FROM wo, itemsite
  WHERE ((womatl_wo_id=wo_id)
    AND  (womatl_itemsite_id=itemsite_id)
    AND  (wo_id=pWoid));

  IF (fetchMetricBool('Routings')) THEN

      UPDATE xtmfg.wooper
         SET wooper_rntime = CASE WHEN ((booitem_rnqtyper = 0) OR (booitem_invproduomratio = 0)) THEN 0
                                  WHEN (NOT booitem_rnrpt) THEN 0
                                  ELSE ( ( booitem_rntime /
                                           booitem_rnqtyper /
                                           booitem_invproduomratio ) * wo_qtyord )
                             END
        FROM xtmfg.booitem, wo
       WHERE ((wooper_wo_id=wo_id)
         AND  (wooper_booitem_id=booitem_id)
         AND  (wo_id=pWoid));
  END IF;

  IF (changeChildren) THEN
    _result := ( SELECT MIN(changeWoQty(wo_id, womatl_qtyreq, TRUE))
                 FROM womatl, wo
                 WHERE ((womatl_itemsite_id=wo_itemsite_id)
                  AND (wo_ordtype='W')
                  AND (womatl_wo_id=pWoid)
                  AND (wo_ordid=pWoid)) );
  END IF;

  RETURN _result;
END;
$$ LANGUAGE 'plpgsql';
