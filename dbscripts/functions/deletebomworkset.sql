CREATE OR REPLACE FUNCTION deleteBOMWorkset(INTEGER) RETURNS INTEGER AS '
DECLARE
  pWorksetid ALIAS FOR $1;

BEGIN

--  All done with the bomwork set indicated by pWorksetid, delete all of it
  DELETE FROM bomwork
  WHERE (bomwork_set_id=pWorksetid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';
