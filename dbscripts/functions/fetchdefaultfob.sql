CREATE OR REPLACE FUNCTION FetchDefaultFob(integer) RETURNS TEXT AS '
DECLARE
  pWarehousId ALIAS FOR $1;
  _returnVal TEXT;
BEGIN
  SELECT warehous_fob INTO _returnVal
  FROM warehous
  WHERE (warehous_id=pWarehousId);
  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
