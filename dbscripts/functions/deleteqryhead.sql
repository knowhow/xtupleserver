CREATE OR REPLACE FUNCTION deleteQryhead(INTEGER) RETURNS INTEGER AS $$
DECLARE
  pqryheadid    ALIAS FOR $1;

BEGIN
  DELETE FROM qryitem WHERE (qryitem_qryhead_id=pqryheadid);
  DELETE FROM qryhead WHERE (qryhead_id=pqryheadid);

  RETURN pqryheadid;
END;
$$
LANGUAGE 'plpgsql';
