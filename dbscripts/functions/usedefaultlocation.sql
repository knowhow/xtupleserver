CREATE OR REPLACE FUNCTION useDefaultLocation(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pItemsiteid ALIAS FOR $1;
  _p RECORD;

BEGIN

  SELECT itemsite_location_id,
         LENGTH(itemsite_location) AS locationlength INTO _p
  FROM itemsite
  WHERE (itemsite_id=pItemsiteid);

  IF (NOT FOUND) THEN
    RETURN FALSE;

  ELSIF (_p.itemsite_location_id <> -1) THEN
    RETURN TRUE;

  ELSIF (_p.locationlength > 0) THEN
    RETURN TRUE;

  ELSE
    RETURN FALSE;
  END IF;

END;
' LANGUAGE 'plpgsql';
