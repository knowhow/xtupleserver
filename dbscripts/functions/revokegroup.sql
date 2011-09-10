CREATE OR REPLACE FUNCTION revokeGroup(TEXT, INTEGER) RETURNS BOOL AS '
DECLARE
  pUsername ALIAS FOR $1;
  pGrpid ALIAS FOR $2;

BEGIN

  DELETE FROM usrgrp
  WHERE ( (usrgrp_username=pUsername)
   AND (usrgrp_grp_id=pGrpid) );

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';

