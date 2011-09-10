
CREATE OR REPLACE FUNCTION formatSoBarcode(INTEGER) RETURNS TEXT IMMUTABLE AS $$
DECLARE
  pSoheadid ALIAS FOR $1;
  _barcode TEXT;
BEGIN

  SELECT ( E'\138SOXX' ||
           LENGTH(TEXT(cohead_number)) || TEXT(cohead_number) ) INTO _barcode
  FROM cohead
  WHERE (cohead_id=pSoheadid);

  RETURN _barcode;

END;
$$ LANGUAGE 'plpgsql';

