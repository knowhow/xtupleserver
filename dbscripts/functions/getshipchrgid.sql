CREATE OR REPLACE FUNCTION getShipChrgId(text) RETURNS INTEGER AS '
DECLARE
  pShipChrgName ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pShipChrgName IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT shipchrg_id INTO _returnVal
  FROM shipchrg
  WHERE (shipchrg_name=pShipChrgName);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Ship Charge % not found.'', pShipChrgName;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
