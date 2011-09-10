CREATE OR REPLACE FUNCTION pkgMayBeModified(NAME) RETURNS BOOLEAN AS $$
DECLARE
  pschemaname ALIAS FOR $1;
  _returnval  BOOLEAN;
BEGIN
  SELECT pkghead_indev INTO _returnval
  FROM pkghead
  WHERE (pkghead_name=pschemaname);
  IF (NOT FOUND) THEN
    RETURN FALSE;
  END IF;
  RETURN _returnval;
END;
$$
LANGUAGE 'plpgsql';
