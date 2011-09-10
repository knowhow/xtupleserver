CREATE OR REPLACE FUNCTION itemUOMFractionalByType(INTEGER, TEXT) RETURNS BOOL AS '
DECLARE
  pItemid ALIAS FOR $1;
  pUomtype ALIAS FOR $2;
  _frac BOOLEAN;
BEGIN
  SELECT itemuomconv_fractional
    INTO _frac
    FROM item
    JOIN itemuomconv ON (itemuomconv_item_id=item_id)
    JOIN itemuom ON (itemuom_itemuomconv_id=itemuomconv_id)
    JOIN uomtype ON (itemuom_uomtype_id=uomtype_id)
   WHERE((item_id=pItemid)
     AND (uomtype_name=pUomtype))
   LIMIT 1;

  IF (NOT FOUND) THEN
    SELECT item_fractional
      INTO _frac
      FROM item
      JOIN uom ON (item_inv_uom_id=uom_id)
     WHERE(item_id=pItemid);
  END IF;

  RETURN _frac;
END;
' LANGUAGE 'plpgsql';
