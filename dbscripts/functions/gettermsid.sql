CREATE OR REPLACE FUNCTION getTermsId(text) RETURNS INTEGER AS '
DECLARE
  pTermsCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pTermsCode IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT terms_id INTO _returnVal
  FROM terms
  WHERE (terms_code=pTermsCode);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Terms Code % not found.'', pTermsCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
