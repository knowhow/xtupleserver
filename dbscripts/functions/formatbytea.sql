CREATE OR REPLACE FUNCTION formatbytea(bytea)
  RETURNS text AS
'
DECLARE
  pField ALIAS FOR $1;
  output_field TEXT;

BEGIN

  output_field := pField;

  RETURN output_field;

END;
'
  LANGUAGE 'plpgsql';
