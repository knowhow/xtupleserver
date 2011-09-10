CREATE OR REPLACE FUNCTION getCmntTypeId(text) RETURNS INTEGER AS '
DECLARE
  pCmntType ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (COALESCE(TRIM(pCmntType), '''') = '''') THEN
    RETURN NULL;
  END IF;

  SELECT cmnttype_id INTO _returnVal
  FROM cmnttype
  WHERE (cmnttype_name=pCmntType) LIMIT 1;

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Comment Type % not found.'', pCmntType;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
