CREATE OR REPLACE FUNCTION getCustTypeId(text) RETURNS INTEGER AS '
DECLARE
  pCustTypeCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pCustTypeCode IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT custtype_id INTO _returnVal
  FROM custtype
  WHERE (custtype_code=pCustTypeCode);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Customer Type % not found.'', pCustTypeCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
