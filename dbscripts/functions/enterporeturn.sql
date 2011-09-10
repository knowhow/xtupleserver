CREATE OR REPLACE FUNCTION enterPoReturn(INTEGER, NUMERIC, INTEGER) RETURNS INTEGER AS '
DECLARE
  pPoitemid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  pRjctcodeid ALIAS FOR $3;
  _porejectid INTEGER;

BEGIN

  SELECT NEXTVAL(''poreject_poreject_id_seq'') INTO _porejectid;

  INSERT INTO poreject
  ( poreject_id, poreject_date, poreject_ponumber, poreject_poitem_id, poreject_trans_username,
    poreject_agent_username, poreject_itemsite_id,
    poreject_vend_id, poreject_vend_item_number, poreject_vend_item_descrip, poreject_vend_uom,
    poreject_qty, poreject_rjctcode_id, poreject_posted, poreject_invoiced )
  SELECT _porejectid, CURRENT_TIMESTAMP, pohead_number, poitem_id, getEffectiveXtUser(),
         pohead_agent_username, poitem_itemsite_id,
         pohead_vend_id, poitem_vend_item_number, poitem_vend_item_descrip, poitem_vend_uom,
         pQty, pRjctcodeid, FALSE, FALSE
  FROM pohead, poitem
  WHERE ( (poitem_pohead_id=pohead_id)
   AND (poitem_id=pPoitemid) );

  RETURN _porejectid;

END;
' LANGUAGE 'plpgsql';
