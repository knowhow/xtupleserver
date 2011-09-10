CREATE OR REPLACE FUNCTION deleteUnusedFreightClasses() RETURNS INTEGER AS '
BEGIN

  DELETE FROM freightclass
  WHERE (freightclass_id NOT IN (SELECT DISTINCT COALESCE(item_freightclass_id, 0) FROM item));

  RETURN 0;

END;
' LANGUAGE 'plpgsql';
