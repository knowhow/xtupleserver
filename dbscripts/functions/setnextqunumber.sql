CREATE OR REPLACE FUNCTION setNextQuNumber(INTEGER) RETURNS INTEGER  AS '
DECLARE
  pQuNumber ALIAS FOR $1;
  _orderseqid INTEGER;

BEGIN

  SELECT orderseq_id INTO _orderseqid
  FROM orderseq
  WHERE (orderseq_name=''QuNumber'');

  IF (NOT FOUND) THEN
    SELECT NEXTVAL(''orderseq_orderseq_id_seq'') INTO _orderseqid;

    INSERT INTO orderseq (orderseq_id, orderseq_name, orderseq_number)
    VALUES (_orderseqid, ''QuNumber'', pQuNumber);

  ELSE
    UPDATE orderseq
    SET orderseq_number=pQuNumber
    WHERE (orderseq_name=''QuNumber'');
  END IF;

  RETURN _orderseqid;

END;
' LANGUAGE 'plpgsql';
