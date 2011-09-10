CREATE OR REPLACE FUNCTION getFreightTaxTypeId() RETURNS INTEGER AS '
DECLARE
  _taxtypeid INTEGER;
BEGIN
  SELECT taxtype_id
    INTO _taxtypeid
    FROM taxtype
   WHERE (taxtype_name=''Freight'');

  RETURN _taxtypeid;
END;
' LANGUAGE 'plpgsql' IMMUTABLE;
