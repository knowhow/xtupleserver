CREATE OR REPLACE FUNCTION avgCost(INTEGER) RETURNS NUMERIC AS $$
DECLARE
  pItemsiteid ALIAS FOR $1;
  _value NUMERIC;
  _qoh NUMERIC;
BEGIN
  SELECT itemsite_value, itemsite_qtyonhand
    INTO _value, _qoh
    FROM itemsite
   WHERE(itemsite_id=pItemsiteid);
  IF (_qoh = 0) THEN
    RETURN 0;
  END IF;
  RETURN _value / _qoh;
END;
$$ LANGUAGE 'plpgsql';

