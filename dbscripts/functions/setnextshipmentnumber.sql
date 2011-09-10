CREATE OR REPLACE FUNCTION setNextShipmentNumber(INTEGER) RETURNS INTEGER  AS '
DECLARE
  pShipmentNumber ALIAS FOR $1;
  _orderseqid INTEGER;

BEGIN

  SELECT orderseq_id INTO _orderseqid
  FROM orderseq
  WHERE (orderseq_name=''ShipmentNumber'');

  IF (NOT FOUND) THEN
    SELECT NEXTVAL(''orderseq_orderseq_id_seq'') INTO _orderseqid;

    INSERT INTO orderseq (orderseq_id, orderseq_name, orderseq_number)
    VALUES (_orderseqid, ''ShipmentNumber'', pShipmentNumber);

  ELSE
    UPDATE orderseq
    SET orderseq_number=pShipmentNumber
    WHERE (orderseq_name=''ShipmentNumber'');
  END IF;

  RETURN _orderseqid;

END;
' LANGUAGE 'plpgsql';
