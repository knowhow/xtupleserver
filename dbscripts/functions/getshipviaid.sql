CREATE OR REPLACE FUNCTION getShipViaId(text) RETURNS INTEGER AS '
DECLARE
  pShipViaCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pShipViaCode IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT shipvia_id INTO _returnVal
  FROM shipvia
  WHERE (shipvia_code=pShipViaCode);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''ShipVia Code % not found.'', pShipViaCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
