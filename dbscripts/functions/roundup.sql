
CREATE OR REPLACE FUNCTION roundUp(NUMERIC) RETURNS NUMERIC IMMUTABLE AS '
DECLARE

  pValue ALIAS FOR $1;
  _checkValue integer;

BEGIN

  _checkValue := pValue::integer;

  IF (_checkValue::numeric < pValue) THEN
    RETURN (_checkValue + 1)::numeric;
  ELSE
    RETURN _checkValue::numeric;
  END IF;

END;
' LANGUAGE 'plpgsql';

