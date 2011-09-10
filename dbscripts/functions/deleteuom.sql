CREATE OR REPLACE FUNCTION deleteUOM(INTEGER) RETURNS INTEGER AS '
DECLARE
  pUomid ALIAS FOR $1;

BEGIN

  DELETE FROM uomconv WHERE uomconv_from_uom_id=pUomid;
  DELETE FROM uomconv WHERE uomconv_to_uom_id=pUomid;
  DELETE FROM uom WHERE uom_id=pUomid;

  RETURN 0;
END;
' LANGUAGE 'plpgsql';
