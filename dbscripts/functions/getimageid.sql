CREATE OR REPLACE FUNCTION getImageId(text) RETURNS INTEGER AS '
DECLARE
  pImageName ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (COALESCE(TRIM(pImageName), '''') = '''') THEN
    RETURN NULL;
  END IF;

  SELECT image_id INTO _returnVal
  FROM image
  WHERE (image_name=pImageName);

  IF (_returnVal IS NULL) THEN
    RAISE EXCEPTION ''Image % not found.'', pImageName;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
