CREATE OR REPLACE FUNCTION itemuomtouom(INTEGER, INTEGER, INTEGER, NUMERIC) RETURNS NUMERIC AS '
DECLARE
  pItemid ALIAS FOR $1;
  pUomidFrom ALIAS FOR $2;
  pUomidTo ALIAS FOR $3;
  pQtyFrom ALIAS FOR $4;

  _uomidFrom INTEGER;
  _uomidTo   INTEGER;
  _valueFrom NUMERIC;
  _valueTo   NUMERIC;
  _item      RECORD;
  _conv      RECORD;
  _frac      BOOLEAN;
BEGIN

  SELECT item_inv_uom_id, item_fractional
    INTO _item
    FROM item
   WHERE(item_id=pItemid);
  IF(NOT FOUND) THEN
    RAISE EXCEPTION ''No item record was found for item id %'', pItemid;
  END IF;

  _uomidFrom := COALESCE(pUomidFrom, _item.item_inv_uom_id);
  _uomidTo   := COALESCE(pUomidTo,   _item.item_inv_uom_id);

  -- Should we round the qty here or not?
  IF(_uomidFrom = _uomidTo) THEN
    -- Both from/to are the same. If it is the item inv uom
    -- then use the item fractional value otherwise assume
    -- it is fractional for now so the user gets the same value back.
    IF(_uomidFrom = _item.item_inv_uom_id) THEN
      _frac := _item.item_fractional;
    ELSE
      _frac := true;
    END IF;
    RETURN roundQty(_frac, pQtyFrom);
  END IF;

  IF(_uomidFrom != _item.item_inv_uom_id AND _uomidTo != _item.item_inv_uom_id) THEN
    RAISE EXCEPTION ''Converting from/to a UOM where one is not the inventory UOM is currently not supported'';
  END IF;

  SELECT itemuomconv_from_uom_id, itemuomconv_from_value,
         itemuomconv_to_uom_id, itemuomconv_to_value,
         itemuomconv_fractional
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

  -- If we are converting to the item inv uom use the item fractional value
  -- otherwise use the conversion fractional value.
  if(_uomidTo = _item.item_inv_uom_id) THEN
    _frac := _item.item_fractional;
  ELSE
    _frac := _conv.itemuomconv_fractional;
  END IF;

  RETURN roundQty(_frac, ((_valueTo/_valueFrom) * pQtyFrom));
END;
' LANGUAGE 'plpgsql';

