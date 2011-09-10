
CREATE OR REPLACE FUNCTION setNextARMemoNumber(INTEGER) RETURNS INTEGER AS '
DECLARE
  pNumber ALIAS FOR $1;
  _orderseqid INTEGER;

BEGIN

  SELECT orderseq_id INTO _orderseqid
  FROM orderseq
  WHERE (orderseq_name=''ARMemoNumber'');
  IF (FOUND) THEN
    UPDATE orderseq
    SET orderseq_number=pNumber
    WHERE (orderseq_id=_orderseqid);

  ELSE
    INSERT INTO orderseq
    (orderseq_name, orderseq_number)
    VALUES
    (''ARMemoNumber'', pNumber);
  END IF;

  RETURN 1;

END;
' LANGUAGE 'plpgsql';

