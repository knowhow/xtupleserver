SELECT dropIfExists('FUNCTION', 'fetchQuNumber()', 'public');

CREATE OR REPLACE FUNCTION fetchQuNumber() RETURNS TEXT AS $$
DECLARE
  _quNumber TEXT;
  _test INTEGER;

BEGIN

  LOOP

    SELECT CAST(orderseq_number AS text) INTO _quNumber
    FROM orderseq
    WHERE (orderseq_name='QuNumber');

    UPDATE orderseq
    SET orderseq_number = (orderseq_number + 1)
    WHERE (orderseq_name='QuNumber');

    SELECT quhead_id INTO _test
    FROM quhead
    WHERE (quhead_number=_quNumber);

    IF (NOT FOUND) THEN
      EXIT;
    END IF;

  END LOOP;

  RETURN _quNumber;

END;
$$ LANGUAGE 'plpgsql';
