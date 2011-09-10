CREATE OR REPLACE FUNCTION updateListPrice(INTEGER, NUMERIC) RETURNS NUMERIC AS '
DECLARE
  pItemid ALIAS FOR $1;
  pUpdateBy ALIAS FOR $2;

BEGIN

  UPDATE item
  SET item_listprice = (item_listprice * pUpdateBy)
  WHERE (item_id=pItemid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';
