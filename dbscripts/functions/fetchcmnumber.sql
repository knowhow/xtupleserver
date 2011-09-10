CREATE OR REPLACE FUNCTION fetchCMNumber() RETURNS text AS $$
DECLARE
  _number text;
  _test INTEGER;

BEGIN

  LOOP

    SELECT CAST(orderseq_number AS text) INTO _number
    FROM orderseq
    WHERE (orderseq_name='CmNumber')
    FOR UPDATE;

    UPDATE orderseq
    SET orderseq_number = (orderseq_number + 1)
    WHERE (orderseq_name='CmNumber');

    SELECT cmhead_id INTO _test
    FROM cmhead
    WHERE (cmhead_number=_number);

    CONTINUE WHEN FOUND;

    SELECT aropen_id INTO _test
    FROM aropen
    WHERE ( (aropen_doctype IN ('D', 'C', 'R'))
     AND (aropen_docnumber=_number) );

    CONTINUE WHEN FOUND;

    EXIT;

  END LOOP;

  RETURN _number;

END;
$$ LANGUAGE plpgsql;
