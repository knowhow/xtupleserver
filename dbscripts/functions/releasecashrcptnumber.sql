
CREATE OR REPLACE FUNCTION releaseCashRcptNumber(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN

--  Check to see if a Cash Receipt exists with the passed number
  SELECT cashrcpt_id INTO _test
  FROM cashrcpt
  WHERE (cashrcpt_number=CAST(pNumber AS TEXT));

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if CashRcptNumber orderseq has been incremented past the passed number
  SELECT orderseq_number INTO _test
  FROM orderseq
  WHERE (orderseq_name=''CashRcptNumber'');

  IF ((_test - 1) <> pNumber) THEN
    RETURN FALSE;
  END IF;

--  Decrement the orderseq, releasing the passed number
  UPDATE orderseq
  SET orderseq_number = (orderseq_number - 1)
  WHERE (orderseq_name=''CashRcptNumber'');

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';

