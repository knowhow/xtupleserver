CREATE OR REPLACE FUNCTION closePo(INTEGER) RETURNS INTEGER AS '
DECLARE
  pPoheadid ALIAS FOR $1;

BEGIN

  UPDATE poitem
  SET poitem_status=''C''
  WHERE (poitem_pohead_id=pPoheadid);

  UPDATE pohead
  SET pohead_status=''C''
  WHERE (pohead_id=pPoheadid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';
