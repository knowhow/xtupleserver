CREATE OR REPLACE FUNCTION postPurchaseOrder(INTEGER) RETURNS INTEGER AS '
DECLARE
  pPoheadid ALIAS FOR $1;

BEGIN

  IF ( ( SELECT (pohead_status=''U'')
         FROM pohead
         WHERE (pohead_id=pPoheadid) ) ) THEN

    UPDATE pohead
    SET pohead_status=''O''
    WHERE (pohead_id=pPoheadid);

  END IF;

  UPDATE poitem
  SET poitem_status=''O''
  WHERE (poitem_pohead_id=pPoheadid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';
