CREATE OR REPLACE FUNCTION deleteClassCode(INTEGER) RETURNS INTEGER AS '
DECLARE
  pClasscodeid ALIAS FOR $1;
  _check INTEGER;

BEGIN

--  Check to see if any items are assigned to the passed classcode
  SELECT item_id INTO _check
  FROM item
  WHERE (item_classcode_id=pClasscodeid)
  LIMIT 1;
  IF (FOUND) THEN
    RETURN -1;
  END IF;

--  Delete the passed classcode
  DELETE FROM classcode
  WHERE (classcode_id=pClasscodeid);

  RETURN pClasscodeid;

END;
' LANGUAGE 'plpgsql';
