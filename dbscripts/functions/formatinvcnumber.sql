
CREATE OR REPLACE FUNCTION formatInvcNumber(INTEGER) RETURNS TEXT IMMUTABLE AS '
DECLARE
  pCobmiscid ALIAS FOR $1;

BEGIN
  RETURN ( SELECT COALESCE(cobmisc_invcnumber::TEXT, '''')
           FROM cobmisc
           WHERE (cobmisc_id=pCobmiscid) );
END;
' LANGUAGE 'plpgsql';

