CREATE OR REPLACE FUNCTION deleteCreditMemo(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pCmheadid ALIAS FOR $1;

BEGIN

  DELETE FROM cmitem
  WHERE (cmitem_cmhead_id=pCmheadid);

  DELETE FROM cmhead
  WHERE (cmhead_id=pCmheadid);

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
