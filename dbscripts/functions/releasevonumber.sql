CREATE OR REPLACE FUNCTION releaseVoNumber(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pVoNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN

--  Check to see if a Voucher exists with the passed Voucher Number
  SELECT vohead_id INTO _test
  FROM vohead
  WHERE (vohead_number=text(pVoNumber));

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if VcNumber orderseq has been incremented past the passed Voucher Number
  SELECT orderseq_number INTO _test
  FROM orderseq
  WHERE (orderseq_name=''VcNumber'');

  IF ((_test - 1) <> pVoNumber) THEN
    RETURN FALSE;
  END IF;

--  Decrement the VcNumber orderseq, releasing the passed Voucher Number
  UPDATE orderseq
  SET orderseq_number = (orderseq_number - 1)
  WHERE (orderseq_name=''VcNumber'');

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
