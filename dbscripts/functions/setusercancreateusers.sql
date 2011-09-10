CREATE OR REPLACE FUNCTION setuserCanCreateUsers(TEXT, BOOLEAN) RETURNS BOOLEAN AS '
DECLARE
  pUsername ALIAS FOR $1;
  pCreateUser ALIAS FOR $2;

BEGIN

  IF (pCreateUser) THEN
    EXECUTE ''ALTER USER '' || pUsername || '' CREATEUSER;'';
  ELSE
    EXECUTE ''ALTER USER '' || pUsername || '' NOCREATEUSER;'';
  END IF;

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
