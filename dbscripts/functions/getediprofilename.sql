
CREATE OR REPLACE FUNCTION getEdiProfileName(INTEGER) RETURNS TEXT AS $$
DECLARE
  pEdiProfileId ALIAS FOR $1;
  _returnVal TEXT;
BEGIN
  IF (pEdiProfileId IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT pkghead_name INTO _returnVal
    FROM pkghead
   WHERE(pkghead_name='xtbatch');
  IF(NOT FOUND) THEN
    RETURN NULL;
  END IF;

  SELECT ediprofile_name INTO _returnVal
  FROM xtbatch.ediprofile
  WHERE (ediprofile_id=pEdiProfileId);

  RETURN _returnVal;
END;
$$ LANGUAGE 'plpgsql';

