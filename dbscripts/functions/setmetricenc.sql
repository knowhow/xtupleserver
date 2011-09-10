CREATE OR REPLACE FUNCTION setmetricenc(text, text, text)
  RETURNS bool AS
'
DECLARE
  pMetricName ALIAS FOR $1;
  pMetricValue ALIAS FOR $2;
  pMetricEnc ALIAS FOR $3;
  _metricid INTEGER;
  _value bytea;
  _key bytea;

BEGIN

  _value = decode(pMetricValue, ''escape'');
  _key = decode(pMetricEnc, ''escape'');

  SELECT metricenc_id INTO _metricid
  FROM metricenc
  WHERE (metricenc_name=pMetricName);

  IF (FOUND) THEN
    UPDATE metricenc
    SET metricenc_value=encrypt(_value, _key, ''bf'')
    WHERE (metricenc_id=_metricid);

  ELSE
    INSERT INTO metricenc
    (metricenc_name, metricenc_value)
    VALUES (pMetricName, encrypt(_value, _key, ''bf''));
  END IF;

  RETURN TRUE;

END;
'
  LANGUAGE 'plpgsql';
