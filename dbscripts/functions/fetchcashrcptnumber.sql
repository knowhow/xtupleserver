
CREATE OR REPLACE FUNCTION fetchCashRcptNumber() RETURNS TEXT AS '
DECLARE
  _number TEXT;
  _test INTEGER;

BEGIN

  LOOP

    SELECT CAST(orderseq_number AS text) INTO _number
    FROM orderseq
    WHERE (orderseq_name=''CashRcptNumber'');
    IF (NOT FOUND) THEN
      RETURN -1;
    END IF;

    UPDATE orderseq
    SET orderseq_number = (orderseq_number + 1)
    WHERE (orderseq_name=''CashRcptNumber'');

    SELECT cashrcpt_id INTO _test
    FROM cashrcpt
    WHERE (cashrcpt_number=_number);

    IF (NOT FOUND) THEN
      EXIT;
    END IF;

  END LOOP;

  RETURN _number;

END;
' LANGUAGE 'plpgsql';

