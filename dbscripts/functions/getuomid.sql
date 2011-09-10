CREATE OR REPLACE FUNCTION getUomId(text) RETURNS INTEGER AS '
DECLARE
  pUom ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pUom IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT uom_id INTO _returnVal
  FROM uom
  WHERE (uom_name=pUom);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Unit of Measure % not found.'', pUom;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
