SELECT dropIfExists('FUNCTION', 'releaseQuNumber(integer)', 'public');
SELECT dropIfExists('FUNCTION', 'releaseQuNumber(text)', 'public');

CREATE OR REPLACE FUNCTION releaseQuNumber(INTEGER) RETURNS INTEGER AS $$
DECLARE
  pQuNumber ALIAS FOR $1;

BEGIN
  RETURN releaseQuNumber(pQuNumber::TEXT);

END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION releaseQuNumber(TEXT) RETURNS INTEGER AS $$
DECLARE
  pQuNumber ALIAS FOR $1;
  _test INTEGER;

BEGIN
--  Check to see if a Quote exists with the passed Quote Number
  SELECT quhead_id INTO _test
  FROM quhead
  WHERE (quhead_number=pQuNumber);

  IF (FOUND) THEN
    RETURN -1;
  END IF;

--  Check to see if QuNumber orderseq has been incremented past the passed Quote Number
  SELECT orderseq_number INTO _test
  FROM orderseq
  WHERE (orderseq_name='QuNumber');

  IF ((_test - 1) <> CAST(pQuNumber AS INTEGER)) THEN
    RETURN -2;
  END IF;

--  Decrement the QuNumber orderseq, releasing the passed Quote Number
  UPDATE orderseq
  SET orderseq_number = (orderseq_number - 1)
  WHERE (orderseq_name='QuNumber');

  RETURN 0;

END;
$$ LANGUAGE 'plpgsql';
