CREATE OR REPLACE FUNCTION explodeWoEffective() RETURNS TEXT AS '
DECLARE
  _value TEXT;

BEGIN

  SELECT metric_value INTO _value
  FROM metric
  WHERE (metric_name=''ExplodeWOEffective'');

  RETURN _value;

END;
' LANGUAGE 'plpgsql';