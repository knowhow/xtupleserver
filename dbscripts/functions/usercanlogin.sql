
CREATE OR REPLACE FUNCTION userCanLogin(TEXT) RETURNS bool AS $$
DECLARE
  pUsername ALIAS FOR $1;
  _result TEXT;
  _default TEXT;
BEGIN
  IF(pg_has_role(pUsername, 'xtrole', 'member')) THEN
    SELECT metric_value
      INTO _default
      FROM metric
     WHERE metric_name = 'AllowedUserLogins';
    IF (COALESCE(_default,'') NOT IN ('AdminOnly','ActiveOnly','Any')) THEN
      _default := 'ActiveOnly';
    END IF;

    SELECT usrpref_value
      INTO _result
      FROM usrpref
     WHERE usrpref_username = pUsername
       AND usrpref_name = 'active';
    IF (COALESCE(_result,'') NOT IN ('t','f')) THEN
      IF(_default='Any') THEN
        _result := 't';
      ELSE
        _result := 'f';
      END IF;
    END IF;

    IF(_result = 't') THEN
      IF(_default='AdminOnly' AND userCanCreateUsers(pUsername)!=true) THEN
        RETURN false;
      END IF;
      RETURN true;
    END IF;
  END IF;
  RETURN false;
END;
$$ LANGUAGE 'plpgsql';

