CREATE OR REPLACE FUNCTION deleteUnusedClassCodes() RETURNS INTEGER AS '
BEGIN

  DELETE FROM classcode
  WHERE (classcode_id NOT IN (SELECT DISTINCT item_classcode_id FROM item));

  RETURN 0;

END;
' LANGUAGE 'plpgsql';
