CREATE OR REPLACE FUNCTION grantGroup(TEXT, INTEGER) RETURNS BOOL AS '
DECLARE
  pUsername ALIAS FOR $1;
  pGrpid ALIAS FOR $2;
  _test INTEGER;

BEGIN

  SELECT usrgrp_id INTO _test
  FROM usrgrp
  WHERE ( (usrgrp_username=pUsername)
   AND (usrgrp_grp_id=pGrpid) );

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

  INSERT INTO usrgrp
  ( usrgrp_username, usrgrp_grp_id )
  VALUES
  ( pUsername, pGrpid );

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';

