CREATE OR REPLACE FUNCTION getVendTypeId(text) RETURNS INTEGER AS '
DECLARE
  pVendTypeCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pVendTypeCode IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT vendtype_id INTO _returnVal
  FROM vendtype
  WHERE (UPPER(vendtype_code)=UPPER(pVendTypeCode));

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Vendor Type % not found.'', pVendTypeCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
