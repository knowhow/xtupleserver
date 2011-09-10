CREATE OR REPLACE FUNCTION releaseInvcNumber(INTEGER) RETURNS BOOLEAN AS '
BEGIN
  RETURN releaseInvcNumber(CAST($1 AS TEXT));
END;
' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION releaseInvcNumber(TEXT) RETURNS BOOLEAN AS '
DECLARE
  pNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN

--  Check to see if a Invoice exists with the passed Number
  SELECT invchead_id INTO _test
  FROM invchead
  WHERE (invchead_invcnumber=pNumber);

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

--  Check to see if InvcNumber orderseq has been incremented past the passed Number
  SELECT orderseq_number INTO _test
  FROM orderseq
  WHERE (orderseq_name=''InvcNumber'');

  IF (CAST(_test   AS INTEGER) - 1 <>
      CAST(pNumber AS INTEGER)) THEN
    RETURN FALSE;
  END IF;

--  Decrement the InvcNumber orderseq, releasing the passed Invc Number
  UPDATE orderseq
  SET orderseq_number = (orderseq_number - 1)
  WHERE (orderseq_name=''InvcNumber'');

  RETURN TRUE;

END;
' LANGUAGE plpgsql;
