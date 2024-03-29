CREATE OR REPLACE FUNCTION deleteProductCategory(INTEGER) RETURNS INTEGER AS '
DECLARE
  pProdcatid ALIAS FOR $1;
  _check INTEGER;

BEGIN

--  Check to see if any items are assigned to the passed classcode
  SELECT item_id INTO _check
  FROM item
  WHERE (item_prodcat_id=pProdcatid)
  LIMIT 1;
  IF (FOUND) THEN
    RETURN -1;
  END IF;

--  Delete any assocated records
  DELETE FROM salesaccnt
  WHERE (salesaccnt_prodcat_id=pProdcatid);

--  Delete the passed prodcat
  DELETE FROM prodcat
  WHERE (prodcat_id=pProdcatid);

  RETURN pProdcatid;

END;
' LANGUAGE 'plpgsql';
