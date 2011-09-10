CREATE OR REPLACE FUNCTION FetchMetricText(text) RETURNS TEXT STABLE AS '
DECLARE
  _pMetricName ALIAS FOR $1;
  _returnVal TEXT;
BEGIN
  SELECT metric_value::TEXT INTO _returnVal
    FROM metric
   WHERE metric_name = _pMetricName;
  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
