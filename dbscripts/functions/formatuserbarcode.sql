
CREATE OR REPLACE FUNCTION formatUserBarcode(INTEGER) RETURNS TEXT IMMUTABLE AS $$
DECLARE
  pUserid ALIAS FOR $1;
  _barcode TEXT;
BEGIN

  SELECT formatUserBarcode(usr_username) INTO _barcode
    FROM usr
   WHERE(usr_id=pUserid);

  RETURN _barcode;

END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION formatUserBarcode(TEXT) RETURNS TEXT IMMUTABLE AS $$
DECLARE
  pUsername ALIAS FOR $1;
  _barcode TEXT;
BEGIN

  _barcode := ( E'\138USER' || LENGTH(pUsername)::TEXT || pUsername );

  RETURN _barcode;

END;
$$ LANGUAGE 'plpgsql';

