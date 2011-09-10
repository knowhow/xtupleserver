
CREATE OR REPLACE FUNCTION currentCashRcptNumber() RETURNS INTEGER AS '
DECLARE
  _number INTEGER;

BEGIN

  SELECT orderseq_number INTO _number
  FROM orderseq
  WHERE (orderseq_name=''CashRcptNumber'');
  IF (NOT FOUND) THEN
    _number := 0;
  END IF;

  RETURN _number;

END;
' LANGUAGE 'plpgsql';

