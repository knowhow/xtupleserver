CREATE OR REPLACE FUNCTION itemInventoryUOMInUse(INTEGER) RETURNS BOOLEAN AS '
DECLARE
  pItemid ALIAS FOR $1;
  _uomid INTEGER;
  _result INTEGER;
BEGIN
  SELECT item_inv_uom_id INTO _uomid
    FROM item
   WHERE(item_id=pItemid);

  SELECT itemuomconv_id INTO _result
    FROM itemuomconv
   WHERE(itemuomconv_item_id=pItemid)
   LIMIT 1;
  IF (FOUND) THEN
    RETURN TRUE;
  END IF;

  SELECT itemsite_id INTO _result
  FROM itemsite WHERE ( (itemsite_item_id=pItemid)
                  AND   ((itemsite_qtyonhand <> 0) OR (itemsite_nnqoh <> 0)) )
  LIMIT 1;
  IF (FOUND) THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END;
' LANGUAGE 'plpgsql';
