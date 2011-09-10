CREATE OR REPLACE FUNCTION markCheckASPosted(INTEGER) RETURNS INTEGER AS '
DECLARE
  pCheckid ALIAS FOR $1;

BEGIN

  UPDATE checkhead
  SET checkhead_posted=TRUE
  WHERE (checkhead_id=pCheckid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';
