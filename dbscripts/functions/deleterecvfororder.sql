CREATE OR REPLACE FUNCTION deleteRecvForOrder(TEXT, INTEGER) RETURNS INTEGER AS '
DECLARE
  pordertype	ALIAS FOR $1;
  porderid	ALIAS FOR $2;

BEGIN
  DELETE FROM recv
  USING orderitem
  WHERE ((recv_orderitem_id=orderitem_id)
    AND  (recv_order_type=orderitem_orderhead_type)
    AND  (NOT recv_posted)
    AND  (orderitem_orderhead_id=porderid)
    AND  (orderitem_orderhead_type=pordertype));

  RETURN 0;

END;
' LANGUAGE 'plpgsql';
