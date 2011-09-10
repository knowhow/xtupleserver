CREATE OR REPLACE FUNCTION formatLotSerialNumber(INTEGER) RETURNS TEXT AS '
DECLARE
  pLotSerialId ALIAS FOR $1;
  _lotserial TEXT;

BEGIN
  --See if lot serial control turned on (Postbooks will not ever have this)
  IF (fetchmetricbool(''LotSerialControl'')) THEN
    SELECT ls_number INTO _lotserial
    FROM ls
    WHERE (ls_id=pLotSerialId);
  END IF;

  RETURN COALESCE(_lotserial,'''');

END;
' LANGUAGE 'plpgsql';