CREATE OR REPLACE FUNCTION getUsrId(text) RETURNS INTEGER AS $$
DECLARE
  pUsr ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  SELECT usr_id INTO _returnVal
  FROM usr
  WHERE (usr_username=COALESCE(pUsr, getEffectiveXtUser()));

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION 'User % not found.', pUsr;
  END IF;

  RETURN _returnVal;
END;
$$ LANGUAGE 'plpgsql';
