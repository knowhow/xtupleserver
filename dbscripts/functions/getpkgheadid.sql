CREATE OR REPLACE FUNCTION getPkgheadId(text) RETURNS INTEGER AS $$
DECLARE
  ppkgname ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (ppkgname IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT pkghead_id INTO _returnVal
  FROM pkghead
  WHERE (UPPER(pkghead_name)=UPPER(ppkgname));

  IF (_returnVal IS NULL) THEN
    RAISE EXCEPTION 'Package % not found.', ppkgname;
  END IF;

  RETURN _returnVal;
END;
$$ LANGUAGE 'plpgsql';
