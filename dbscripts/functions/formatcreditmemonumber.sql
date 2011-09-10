
CREATE OR REPLACE FUNCTION formatCreditMemoNumber(INTEGER) RETURNS TEXT IMMUTABLE AS '
DECLARE
  pCmheadid ALIAS FOR $1;

BEGIN
  RETURN ( SELECT COALESCE(cmhead_number::TEXT, '''')
           FROM cmhead
           WHERE (cmhead_id=pCmheadid) );
END;
' LANGUAGE 'plpgsql';

