CREATE OR REPLACE FUNCTION revokeAllModulePrivGroup(INTEGER, TEXT) RETURNS INTEGER AS '
DECLARE
  pGrpid ALIAS FOR $1;
  pModuleName ALIAS FOR $2;

BEGIN

  DELETE FROM grppriv
  WHERE (grppriv_id IN ( SELECT grppriv_id
                         FROM grppriv, priv
                         WHERE ( (grppriv_priv_id=priv_id)
                          AND (grppriv_grp_id=pGrpid)
                          AND (priv_module=pModuleName) ) ) );

  RETURN 1;

END;
' LANGUAGE 'plpgsql';

