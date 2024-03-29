CREATE OR REPLACE FUNCTION setNextWoNumber(INTEGER) RETURNS INTEGER  AS '
DECLARE
  pWoNumber ALIAS FOR $1;
  _orderseqid INTEGER;

BEGIN

  SELECT orderseq_id INTO _orderseqid
  FROM orderseq
  WHERE (orderseq_name=''WoNumber'');

  IF (NOT FOUND) THEN
    SELECT NEXTVAL(''orderseq_orderseq_id_seq'') INTO _orderseqid;

    INSERT INTO orderseq (orderseq_id, orderseq_name, orderseq_number)
    VALUES (_orderseqid, ''WoNumber'', pWoNumber);

  ELSE
    UPDATE orderseq
    SET orderseq_number=pWoNumber
    WHERE (orderseq_name=''WoNumber'');
  END IF;

  RETURN _orderseqid;

END;
' LANGUAGE 'plpgsql';