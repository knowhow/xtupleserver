
CREATE OR REPLACE FUNCTION formatWoNumber(integer) RETURNS TEXT IMMUTABLE AS '
DECLARE
  pWoid ALIAS FOR $1;

BEGIN

  RETURN ( SELECT (wo_number::TEXT || ''-'' || wo_subnumber::TEXT)
           FROM wo
           WHERE (wo_id=pWoid) );

END;
' LANGUAGE 'plpgsql';

