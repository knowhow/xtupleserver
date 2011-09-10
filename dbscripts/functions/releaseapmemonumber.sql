CREATE OR REPLACE FUNCTION releaseAPMemoNumber(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN

--  Check to see if a A/R Open Item exists with the passed number
  SELECT apopen_id INTO _test
  FROM apopen
  WHERE ( (apopen_doctype IN (''D'', ''C''))
   AND (apopen_docnumber=CAST(pNumber AS TEXT)) );

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if APMemoNumber orderseq has been incremented past the passed number
  SELECT orderseq_number INTO _test
  FROM orderseq
  WHERE (orderseq_name=''APMemoNumber'');

  IF ((_test - 1) <> pNumber) THEN
    RETURN FALSE;
  END IF;

--  Decrement the orderseq, releasing the passed number
  UPDATE orderseq
  SET orderseq_number = (orderseq_number - 1)
  WHERE (orderseq_name=''APMemoNumber'');

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
