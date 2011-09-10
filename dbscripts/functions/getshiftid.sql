CREATE OR REPLACE FUNCTION getShiftId(text) RETURNS INTEGER AS '
DECLARE
  pShiftNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (COALESCE(TRIM(pShiftNumber), '''') = '''') THEN
      RETURN NULL;
  END IF;

  SELECT shift_id INTO _returnVal
  FROM shift
  WHERE (UPPER(shift_number)=UPPER(pShiftNumber));

  IF (_returnVal IS NULL) THEN
    RAISE EXCEPTION ''Shift % not found.'', pShiftNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
