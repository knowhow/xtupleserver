
CREATE OR REPLACE FUNCTION releaseARMemoNumber(INTEGER) RETURNS BOOLEAN AS $$
DECLARE
  pNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN

--  Check to see if a A/R Open Item exists with the passed number
  SELECT aropen_id INTO _test
  FROM aropen
  WHERE ( (aropen_doctype IN ('D', 'C', 'R'))
   AND (aropen_docnumber=CAST(pNumber AS TEXT)) );

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if a C/M exists with the passed C/M Number
  SELECT cmhead_id INTO _test
  FROM cmhead
  WHERE (cmhead_number=CAST(pNumber AS TEXT));

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if ARMemoNumber orderseq has been incremented past the passed number
  SELECT orderseq_number INTO _test
  FROM orderseq
  WHERE (orderseq_name='ARMemoNumber');

  IF ((_test - 1) <> pNumber) THEN
    RETURN FALSE;
  END IF;

--  Decrement the orderseq, releasing the passed number
  UPDATE orderseq
  SET orderseq_number = (orderseq_number - 1)
  WHERE (orderseq_name='ARMemoNumber');

  RETURN TRUE;

END;
$$ LANGUAGE 'plpgsql';

