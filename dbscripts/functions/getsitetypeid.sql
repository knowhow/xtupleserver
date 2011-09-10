CREATE OR REPLACE FUNCTION getSiteTypeId(text) RETURNS INTEGER AS '
DECLARE
  pSiteType ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pSiteType IS NULL) THEN
	RETURN NULL;
  END IF;

  SELECT sitetype_id INTO _returnVal
  FROM sitetype
  WHERE (sitetype_name=pSiteType);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Site Type % not found.'', pSiteType;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
