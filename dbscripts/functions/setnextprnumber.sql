CREATE OR REPLACE FUNCTION setNextPrNumber(INTEGER) RETURNS INTEGER  AS '
DECLARE
  pNumber ALIAS FOR $1;
  _orderseqid INTEGER;

BEGIN

  SELECT orderseq_id INTO _orderseqid
  FROM orderseq
  WHERE (orderseq_name=''PrNumber'');

  IF (NOT FOUND) THEN
    SELECT NEXTVAL(''orderseq_orderseq_id_seq'') INTO _orderseqid;
    INSERT INTO orderseq (orderseq_id, orderseq_name, orderseq_number)
    VALUES (_orderseqid, ''PrNumber'', pNumber);

  ELSE
    UPDATE orderseq
    SET orderseq_number=pNumber
    WHERE (orderseq_name=''PrNumber'');
  END IF;

  RETURN _orderseqid;

END;
' LANGUAGE 'plpgsql';
