CREATE OR REPLACE FUNCTION releaseCMNumber(INTEGER) RETURNS BOOLEAN AS $$
BEGIN
  RETURN releasecmnumber(CAST($1 AS TEXT));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION releaseCMNumber(TEXT) RETURNS BOOLEAN AS $$
DECLARE
  pNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN

--  Check to see if a C/M exists with the passed C/M Number
  SELECT cmhead_id INTO _test
  FROM cmhead
  WHERE (cmhead_number=pNumber);

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if a A/R Open Item exists with the passed number
  SELECT aropen_id INTO _test
  FROM aropen
  WHERE ( (aropen_doctype IN ('D', 'C', 'R'))
   AND (aropen_docnumber=pNumber) );

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if CmNumber orderseq has been incremented past the passed S/O Number
  SELECT orderseq_number INTO _test
  FROM orderseq
  WHERE (orderseq_name='CmNumber');

  IF (CAST(_test   AS INTEGER) - 1 <>
      CAST(pNumber AS INTEGER)) THEN
    RETURN FALSE;
  END IF;

--  Decrement the CmNumber orderseq, releasing the passed C/M Number
  UPDATE orderseq
  SET orderseq_number = (orderseq_number - 1)
  WHERE (orderseq_name='CmNumber');

  RETURN TRUE;

END;
$$ LANGUAGE plpgsql;
