CREATE OR REPLACE FUNCTION getExpcatId(text) RETURNS INTEGER AS '
DECLARE
  pExpcatCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (COALESCE(TRIM(pExpcatCode), '''') = '''') THEN
    RETURN NULL;
  END IF;

  SELECT expcat_id INTO _returnVal
  FROM expcat
  WHERE (expcat_code=UPPER(pExpcatCode));

  IF (_returnVal IS NULL) THEN
    RAISE EXCEPTION ''Expense Category % not found.'', pExpcatCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
