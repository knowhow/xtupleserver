CREATE OR REPLACE FUNCTION massExpireBomitem(INTEGER, DATE, TEXT) RETURNS BOOLEAN AS '
DECLARE
  pItemid ALIAS FOR $1;
  pExpireDate ALIAS FOR $2;
  pECN ALIAS FOR $3;

BEGIN

  UPDATE bomitem
  SET bomitem_expires=pExpireDate
  WHERE ( (bomitem_expires >= CURRENT_DATE)
   AND (bomitem_item_id=pItemid)
   AND (bomitem_rev_id=getActiveRevId(''BOM'',bomitem_parent_item_id)) );

  RETURN TRUE;
END;
' LANGUAGE 'plpgsql';
