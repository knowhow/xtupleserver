CREATE OR REPLACE FUNCTION markCheckAsPrinted(INTEGER) RETURNS INTEGER AS '
DECLARE
  pCheckid ALIAS FOR $1;

BEGIN

  UPDATE checkhead
  SET checkhead_printed=TRUE
  WHERE (checkhead_id=pCheckid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';
