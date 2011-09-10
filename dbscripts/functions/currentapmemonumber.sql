CREATE OR REPLACE FUNCTION currentAPMemoNumber() RETURNS INTEGER AS '
DECLARE
  _number INTEGER;

BEGIN

  SELECT orderseq_number INTO _number
  FROM orderseq
  WHERE (orderseq_name=''APMemoNumber'');
  IF (NOT FOUND) THEN
    _number := 0;
  END IF;

  RETURN _number;

END;
' LANGUAGE 'plpgsql';
