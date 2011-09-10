CREATE OR REPLACE FUNCTION setbytea(text)
  RETURNS bytea AS
'
DECLARE
  pMetricName ALIAS FOR $1;
  _value bytea;

BEGIN

  _value := decode(pMetricName, ''escape'');

  RETURN _value;

END;
'
  LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION setbytea(bytea)
  RETURNS bytea AS
'
DECLARE
  pMetricName ALIAS FOR $1;
  _value bytea;

BEGIN

  _value := pMetricName;

  RETURN _value;

END;
'
  LANGUAGE 'plpgsql';
