CREATE OR REPLACE FUNCTION FetchMetricValue(text) RETURNS NUMERIC STABLE AS '
DECLARE
  _pMetricName ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  SELECT CASE WHEN (isNumeric(metric_value)) THEN metric_value::INTEGER
              ELSE NULL
         END INTO _returnVal
    FROM metric
   WHERE metric_name = _pMetricName;
  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
