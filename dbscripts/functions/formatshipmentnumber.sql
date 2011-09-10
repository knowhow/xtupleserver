
CREATE OR REPLACE FUNCTION formatShipmentNumber(INTEGER) RETURNS TEXT IMMUTABLE AS '
DECLARE
  pshipheadid    ALIAS FOR $1;
BEGIN
  RETURN ( SELECT COALESCE(shiphead_number::TEXT, '''')
           FROM shiphead
           WHERE (shiphead_id=pshipheadid) );
END;
' LANGUAGE 'plpgsql';

