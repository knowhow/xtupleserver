CREATE OR REPLACE FUNCTION getTaxTypeId(text) RETURNS INTEGER AS '
DECLARE
  pTaxType ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pTaxType IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT taxtype_id INTO _returnVal
  FROM taxtype
  WHERE (taxtype_name=pTaxType);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Tax Type % not found.'', pTaxType;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
