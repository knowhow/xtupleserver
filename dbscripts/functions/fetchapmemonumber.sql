CREATE OR REPLACE FUNCTION fetchAPMemoNumber() RETURNS INTEGER AS $$
DECLARE
  _number INTEGER;
  _test INTEGER;

BEGIN

  LOOP

    SELECT orderseq_number INTO _number
    FROM orderseq
    WHERE (orderseq_name='APMemoNumber');
    IF (NOT FOUND) THEN
      RETURN -1;
    END IF;

    UPDATE orderseq
    SET orderseq_number = (orderseq_number + 1)
    WHERE (orderseq_name='APMemoNumber');

    SELECT apopen_id INTO _test
    FROM apopen
    WHERE ( (apopen_doctype IN ('D', 'C'))
     AND (apopen_docnumber=text(_number)) );

    IF (NOT FOUND) THEN
      EXIT;
    END IF;

  END LOOP;

  RETURN _number;

END;
$$ LANGUAGE 'plpgsql';
