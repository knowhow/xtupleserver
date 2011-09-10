CREATE OR REPLACE FUNCTION revokePrivGroup(INTEGER, INTEGER) RETURNS BOOL AS '
DECLARE
  pGrpid ALIAS FOR $1;
  pPrivid ALIAS FOR $2;

BEGIN

  DELETE FROM grppriv
  WHERE ( (grppriv_grp_id=pGrpid)
   AND (grppriv_priv_id=pPrivid) );

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';

