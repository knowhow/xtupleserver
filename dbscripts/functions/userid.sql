CREATE OR REPLACE FUNCTION userId(TEXT) RETURNS INTEGER AS '
DECLARE
  pUsername ALIAS FOR $1;
  _userId INTEGER;

BEGIN

  SELECT usesysid INTO _userId
  FROM pg_user
  WHERE (usename=pUsername);

  IF (FOUND) THEN
    RETURN _userId;
  ELSE
    RETURN -1;
  END IF;

END;
' LANGUAGE 'plpgsql';
