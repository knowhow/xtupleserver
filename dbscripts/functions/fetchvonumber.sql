CREATE OR REPLACE FUNCTION fetchVoNumber() RETURNS INTEGER AS '
DECLARE
  _voucherNumber INTEGER;
  _test INTEGER;

BEGIN

  LOOP

    SELECT orderseq_number INTO _voucherNumber
    FROM orderseq
    WHERE (orderseq_name=''VcNumber'')
    FOR UPDATE;

    UPDATE orderseq
    SET orderseq_number = (orderseq_number + 1)
    WHERE (orderseq_name=''VcNumber'');

    SELECT vohead_number INTO _test
    FROM vohead
    WHERE (vohead_number=text(_voucherNumber));

    IF (NOT FOUND) THEN
      EXIT;
    END IF;

  END LOOP;

  RETURN _voucherNumber;

END;
' LANGUAGE 'plpgsql';
