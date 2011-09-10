CREATE OR REPLACE FUNCTION FetchPrefWarehousId() RETURNS INTEGER AS '
DECLARE
  _result INTEGER;
BEGIN
    SELECT CAST(usrpref_value AS INTEGER) INTO _result
    FROM usrpref
    WHERE ((usrpref_username=getEffectiveXtUser())
    AND (usrpref_name=''PreferredWarehouse''));

    RETURN _result;
END;
' LANGUAGE 'plpgsql';
