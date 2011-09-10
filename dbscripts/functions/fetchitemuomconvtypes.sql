CREATE OR REPLACE FUNCTION fetchItemUomConvTypes(integer)
  RETURNS text[] AS '
DECLARE
  pItemUomConvId ALIAS FOR $1;
  _p RECORD;
  _result text[];
  _cnt INTEGER;

BEGIN

  _cnt := 0;

  FOR _p IN SELECT
    uomtype_name
  FROM itemuomconv, itemuom, uomtype
  WHERE ((itemuomconv_id=pItemUomConvId)
  AND (itemuomconv_id=itemuom_itemuomconv_id)
  AND (itemuom_uomtype_id=uomtype_id))
  LOOP
    _result[_cnt] := _p.uomtype_name; 
    _cnt := _cnt + 1;
  END LOOP;

  RETURN _result;
END;
' LANGUAGE 'plpgsql';