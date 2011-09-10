CREATE OR REPLACE FUNCTION getShipZoneId(text) RETURNS INTEGER AS '
DECLARE
  pShipZoneName ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pShipZoneName IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT shipzone_id INTO _returnVal
  FROM shipzone
  WHERE (shipzone_name=pShipZoneName);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Ship Zone % not found.'', pShipZoneName;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
