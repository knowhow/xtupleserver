CREATE OR REPLACE FUNCTION getTaxId(text) RETURNS INTEGER AS '
DECLARE
  pTaxCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pTaxCode IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT tax_id INTO _returnVal
  FROM tax
  WHERE (tax_code=pTaxCode);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Tax Code % not found.'', pTaxCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
