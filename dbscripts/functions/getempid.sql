CREATE OR REPLACE FUNCTION getEmpId(text) RETURNS INTEGER AS '
DECLARE
  pEmpCode ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (COALESCE(TRIM(pEmpCode), '''') = '''') THEN
    RETURN NULL;
  END IF;

  SELECT emp_id INTO _returnVal
  FROM emp
  WHERE (UPPER(emp_code)=UPPER(pEmpCode));

  IF (_returnVal IS NULL) THEN
    RAISE EXCEPTION ''Employee % not found.'', pEmpCode;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
