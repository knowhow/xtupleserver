CREATE OR REPLACE FUNCTION getDeptId(text) RETURNS INTEGER AS '
DECLARE
  pDeptNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (COALESCE(TRIM(pDeptNumber), '''') = '''') THEN
    RETURN NULL;
  END IF;

  SELECT dept_id INTO _returnVal
  FROM dept
  WHERE (UPPER(dept_number)=UPPER(pDeptNumber));

  IF (_returnVal IS NULL) THEN
    RAISE EXCEPTION ''Department % not found.'', pDeptNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
