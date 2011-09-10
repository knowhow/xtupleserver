CREATE OR REPLACE FUNCTION getadjustmenttaxtypeid()
  RETURNS integer AS
$BODY$
DECLARE
  _taxtypeid INTEGER;
BEGIN
  SELECT taxtype_id
    INTO _taxtypeid
  FROM taxtype
  WHERE (taxtype_name='Adjustment');

  RETURN _taxtypeid;
END;
$BODY$
  LANGUAGE 'plpgsql' IMMUTABLE;