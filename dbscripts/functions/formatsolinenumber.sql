
CREATE OR REPLACE FUNCTION formatSoLineNumber(INTEGER) RETURNS TEXT AS $$
DECLARE
  pSoitemid ALIAS FOR $1;
  _r RECORD;

BEGIN

  SELECT coitem_linenumber, coitem_subnumber
    INTO _r
    FROM coitem
   WHERE(coitem_id=pSoitemid);

  IF(NOT FOUND) THEN
    RETURN NULL;
  END IF;

  IF(COALESCE(_r.coitem_subnumber, 0) > 0) THEN
    RETURN _r.coitem_linenumber || '.' || _r.coitem_subnumber;
  END IF;

  RETURN _r.coitem_linenumber; 
END;
$$ LANGUAGE 'plpgsql';

