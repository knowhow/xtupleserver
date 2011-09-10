CREATE OR REPLACE FUNCTION currentNumber(TEXT) RETURNS INTEGER AS $$
DECLARE
  pName   ALIAS FOR $1;
  _number INTEGER;

BEGIN
  SELECT orderseq_number INTO _number
  FROM orderseq
  WHERE (orderseq_name=pName);
  IF (NOT FOUND) THEN
    _number := 0;
  END IF;

  RETURN _number;

END;
$$ LANGUAGE 'plpgsql';
