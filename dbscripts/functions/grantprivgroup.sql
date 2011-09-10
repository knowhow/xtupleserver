CREATE OR REPLACE FUNCTION grantPrivGroup(INTEGER, INTEGER) RETURNS BOOL AS '
DECLARE
  pGrpid ALIAS FOR $1;
  pPrivid ALIAS FOR $2;
  _test INTEGER;

BEGIN

  SELECT grppriv_id INTO _test
  FROM grppriv
  WHERE ( (grppriv_grp_id=pGrpid)
   AND (grppriv_priv_id=pPrivid) );

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

  INSERT INTO grppriv
  ( grppriv_grp_id, grppriv_priv_id )
  VALUES
  ( pGrpid, pPrivid );

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
