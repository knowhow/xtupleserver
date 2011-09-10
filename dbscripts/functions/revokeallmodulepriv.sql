CREATE OR REPLACE FUNCTION revokeAllModulePriv(TEXT, TEXT) RETURNS INTEGER AS $$
DECLARE
  pUsername ALIAS FOR $1;
  pModuleName ALIAS FOR $2;

BEGIN

  DELETE FROM usrpriv
  WHERE (usrpriv_id IN ( SELECT usrpriv_id
                         FROM usrpriv, priv
                         WHERE ( (usrpriv_priv_id=priv_id)
                          AND (usrpriv_username=pUsername)
                          AND (priv_module=pModuleName) ) ) );

  RETURN 1;

END;
$$ LANGUAGE 'plpgsql';

