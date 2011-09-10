CREATE OR REPLACE FUNCTION postAropenItems() RETURNS BOOLEAN AS '
BEGIN

  UPDATE aropen
  SET aropen_posted=TRUE
  WHERE (NOT aropen_posted);

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
