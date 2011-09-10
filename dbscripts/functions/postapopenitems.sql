CREATE OR REPLACE FUNCTION postApopenItems() RETURNS BOOLEAN AS '
BEGIN

  UPDATE apopen
  SET apopen_posted=TRUE
  WHERE (NOT apopen_posted);

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
