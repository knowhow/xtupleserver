CREATE OR REPLACE FUNCTION itemuomtouomratio(INTEGER, INTEGER, INTEGER) RETURNS NUMERIC AS '
DECLARE
  pItemid ALIAS FOR $1;
  pUomidFrom ALIAS FOR $2;
  pUomidTo ALIAS FOR $3;

  _uomidFrom INTEGER;
  _uomidTo   INTEGER;
  _valueFrom NUMERIC;
  _valueTo   NUMERIC;
  _item      RECORD;
  _conv      RECORD;
BEGIN

  SELECT item_inv_uom_id
    INTO _item
    FROM item
   WHERE(item_id=pItemid);
  IF(NOT FOUND) THEN
    RAISE EXCEPTION ''No item record was found for item id %'', pItemid;
  END IF;

  _uomidFrom := COALESCE(pUomidFrom, _item.item_inv_uom_id);
  _uomidTo   := COALESCE(pUomidTo,   _item.item_inv_uom_id);

  IF(_uomidFrom = _uomidTo) THEN
    RETURN 1.0;
  END IF;

  IF(_uomidFrom != _item.item_inv_uom_id AND _uomidTo != _item.item_inv_uom_id) THEN
    RAISE EXCEPTION ''Converting from/to a UOM where one is not the inventory UOM is currently not supported'';
  END IF;

  SELECT itemuomconv_from_uom_id, itemuomconv_from_value,
         itemuomconv_to_uom_id, itemuomconv_to_value
    INTO _conv
    FROM itemuomconv
   WHERE(((itemuomconv_from_uom_id=_uomidFrom AND itemuomconv_to_uom_id=_uomidTo)
       OR (itemuomconv_from_uom_id=_uomidTo AND itemuomconv_to_uom_id=_uomidFrom))
     AND (itemuomconv_item_id=pItemid));
  IF(NOT FOUND) THEN
    RAISE EXCEPTION ''A conversion for item_id % from uom_id % to uom_id % was not found.'', pItemid, _uomidFrom, _uomidTo;
  END IF;

  IF(_conv.itemuomconv_from_uom_id=_uomidFrom) THEN
    _valueFrom := _conv.itemuomconv_from_value;
    _valueTo := _conv.itemuomconv_to_value;
  ELSE
    _valueFrom := _conv.itemuomconv_to_value;
    _valueTo := _conv.itemuomconv_from_value;
  END IF;

  RETURN (_valueTo/_valueFrom);
END;
' LANGUAGE 'plpgsql';

