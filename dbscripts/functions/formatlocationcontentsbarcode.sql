
CREATE OR REPLACE FUNCTION formatLocationContentsBarcode(INTEGER) RETURNS TEXT IMMUTABLE AS $$
DECLARE
  pLocationid ALIAS FOR $1;
  _barcode TEXT;
BEGIN

  SELECT ( E'\138LOCN' ||
           LENGTH(warehous_code)::TEXT || LTRIM(TO_CHAR(LENGTH(location_name), '00')) ||
           warehous_code || location_name ) INTO _barcode
  FROM location, warehous
  WHERE ( (location_warehous_id=warehous_id)
   AND (location_id=pLocationid) );

  RETURN _barcode;

END;
$$ LANGUAGE 'plpgsql';

