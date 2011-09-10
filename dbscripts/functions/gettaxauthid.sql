CREATE OR REPLACE FUNCTION getTaxAuthId(text) RETURNS INTEGER AS '
DECLARE
  pTaxAuthCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pTaxAuthCode IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT taxauth_id INTO _returnVal
  FROM taxauth
  WHERE (taxauth_code=pTaxAuthCode);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Tax Authority % not found.'', pTaxAuthCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
