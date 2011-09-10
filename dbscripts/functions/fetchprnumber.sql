CREATE OR REPLACE FUNCTION fetchPrNumber() RETURNS INTEGER AS '
DECLARE
  _number INTEGER;
  _test INTEGER;

BEGIN

  LOOP
    SELECT orderseq_number INTO _number
    FROM orderseq
    WHERE (orderseq_name=''PrNumber'');

    IF NOT (FOUND) THEN
--  Ack!!  Drop in a bogus PrNumber.
      INSERT INTO orderseq
      ( orderseq_name, orderseq_number )
      VALUES
      ( ''PrNumber'', 100000 );
 
      _number := 100000;
    END IF;

    UPDATE orderseq
    SET orderseq_number = (orderseq_number + 1)
    WHERE (orderseq_name=''PrNumber'');

    SELECT pr_id INTO _test
    FROM pr
    WHERE (pr_number=_number);

    IF (NOT FOUND) THEN
      EXIT;
    END IF;
  END LOOP;

  RETURN _number;

END;
' LANGUAGE 'plpgsql';
