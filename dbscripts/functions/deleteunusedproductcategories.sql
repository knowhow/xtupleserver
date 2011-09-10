CREATE OR REPLACE FUNCTION deleteUnusedProductCategories() RETURNS INTEGER AS '
BEGIN

--  Delete any associated records
  DELETE FROM salesaccnt
  WHERE ( (salesaccnt_prodcat_id <> -1)
   AND (salesaccnt_prodcat_id NOT IN (SELECT DISTINCT item_prodcat_id FROM item)) );

  DELETE FROM prodcat
  WHERE (prodcat_id NOT IN (SELECT DISTINCT item_prodcat_id FROM item));

  RETURN 0;

END;
' LANGUAGE 'plpgsql';
