CREATE OR REPLACE FUNCTION detailedNNQOH(INTEGER, BOOLEAN) RETURNS NUMERIC AS '
DECLARE
  pItemsiteid ALIAS FOR $1;
  pABS ALIAS FOR $2;
  _qoh NUMERIC;

BEGIN

  IF (pABS) THEN
    SELECT SUM(noNeg(itemloc_qty)) INTO _qoh
    FROM itemloc, location
    WHERE ( (itemloc_location_id=location_id)
     AND (NOT location_netable)
     AND (itemloc_itemsite_id=pItemsiteid) );
  ELSE
    SELECT SUM(itemloc_qty) INTO _qoh
    FROM itemloc, location
    WHERE ( (itemloc_location_id=location_id)
     AND (NOT location_netable)
     AND (itemloc_itemsite_id=pItemsiteid) );
  END IF;

  IF (_qoh IS NULL) THEN
    _qoh := 0;
  END IF;

  RETURN _qoh;

END;
' LANGUAGE 'plpgsql';
