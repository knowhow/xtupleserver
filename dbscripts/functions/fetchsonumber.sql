CREATE OR REPLACE FUNCTION fetchSoNumber() RETURNS TEXT AS $$
DECLARE
  _soNumber TEXT;
  _test INTEGER;

BEGIN

  LOOP

    SELECT CAST(orderseq_number AS text) INTO _soNumber
    FROM orderseq
    WHERE (orderseq_name='SoNumber');

    UPDATE orderseq
    SET orderseq_number = (orderseq_number + 1)
    WHERE (orderseq_name='SoNumber');

    SELECT cohead_id INTO _test
    FROM cohead
    WHERE (cohead_number=_soNumber);

    IF (NOT FOUND) THEN
      EXIT;
    END IF;

  END LOOP;

  RETURN _soNumber;

END;
$$ LANGUAGE 'plpgsql';
