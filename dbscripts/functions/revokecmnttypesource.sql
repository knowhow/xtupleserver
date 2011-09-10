
CREATE OR REPLACE FUNCTION revokeCmnttypeSource(INTEGER, INTEGER) RETURNS BOOL AS $$
DECLARE
  pCmnttypeid ALIAS FOR $1;
  pSourceid ALIAS FOR $2;

BEGIN

  DELETE FROM cmnttypesource
  WHERE ( (cmnttypesource_cmnttype_id=pCmnttypeid)
    AND (cmnttypesource_source_id=pSourceid) );

  RETURN TRUE;

END;
$$ LANGUAGE 'plpgsql';

