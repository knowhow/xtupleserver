
CREATE OR REPLACE FUNCTION currentARMemoNumber() RETURNS INTEGER AS '
DECLARE
  _number INTEGER;

BEGIN

  SELECT orderseq_number INTO _number
  FROM orderseq
  WHERE (orderseq_name=''ARMemoNumber'');
  IF (NOT FOUND) THEN
    _number := 0;
  END IF;

  RETURN _number;

END;
' LANGUAGE 'plpgsql';

