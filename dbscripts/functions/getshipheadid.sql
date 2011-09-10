CREATE OR REPLACE FUNCTION getShipheadId(text) RETURNS INTEGER AS '
DECLARE
  pShipmentNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pShipmentNumber IS NULL OR pShipmentNumber = '''') THEN
    RETURN NULL;
  END IF;

  SELECT shiphead_id INTO _returnVal
  FROM shiphead
  WHERE (shiphead_number=pShipmentNumber);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Shipment % not found.'', pShipmentNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
