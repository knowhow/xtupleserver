CREATE OR REPLACE FUNCTION releasePrNumber(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN

--  Check to see if a P/R exists with the passed P/R Number
  SELECT pr_id INTO _test
  FROM pr
  WHERE (pr_number=pNumber);

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if the PrNumber orderseq has been incremented past the
--  passed P/R Number
  SELECT orderseq_number INTO _test
  FROM orderseq
  WHERE (orderseq_name=''PrNumber'');

  IF ((_test - 1) <> pNumber) THEN
    RETURN FALSE;
  END IF;

--  Decrement the PrNumber orderseq, releasing the passed P/R Number
  UPDATE orderseq
  SET orderseq_number = (orderseq_number - 1)
  WHERE (orderseq_name=''PrNumber'');

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
