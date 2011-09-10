CREATE OR REPLACE FUNCTION releaseWoNumber(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pWoNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN

--  Check to see if a W/O exists with the passed W/O Number
  SELECT wo_id INTO _test
  FROM wo
  WHERE (wo_number=pWoNumber);

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if WoNumber orderseq has been incremented past the passed W/O Number
  SELECT orderseq_number INTO _test
  FROM orderseq
  WHERE (orderseq_name=''WoNumber'');

  IF ((_test - 1) <> pWoNumber) THEN
    RETURN FALSE;
  END IF;

--  Decrement the WoNumber orderseq, releasing the passed W/O Number
  UPDATE orderseq
  SET orderseq_number = (orderseq_number - 1)
  WHERE (orderseq_name=''WoNumber'');

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';