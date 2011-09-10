SELECT dropIfExists('FUNCTION', 'releaseSoNumber(integer)', 'public');
SELECT dropIfExists('FUNCTION', 'releaseSoNumber(text)', 'public');

CREATE OR REPLACE FUNCTION releaseSoNumber(INTEGER) RETURNS INTEGER AS $$
DECLARE
  pSoNumber ALIAS FOR $1;

BEGIN
  RETURN releaseSoNumber(pSoNumber::TEXT);

END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION releaseSoNumber(TEXT) RETURNS INTEGER AS $$
DECLARE
  pSoNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN
--  Check to see if a S/O exists with the passed S/O Number
  SELECT cohead_id INTO _test
  FROM cohead
  WHERE (cohead_number=pSoNumber);

  IF (FOUND) THEN
    RETURN -1;
  END IF;

--  Check to see if SoNumber orderseq has been incremented past the passed S/O Number
  SELECT orderseq_number INTO _test
  FROM orderseq
  WHERE (orderseq_name='SoNumber');

  IF ((_test - 1) <> CAST(pSoNumber AS INTEGER)) THEN
    RETURN -2;
  END IF;

--  Decrement the SoNumber orderseq, releasing the passed S/O Number
  UPDATE orderseq
  SET orderseq_number = (orderseq_number - 1)
  WHERE (orderseq_name='SoNumber');

  RETURN 0;

END;
$$ LANGUAGE 'plpgsql';
