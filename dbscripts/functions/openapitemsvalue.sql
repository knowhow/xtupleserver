CREATE OR REPLACE FUNCTION openAPItemsValue(INTEGER, INTEGER) RETURNS NUMERIC AS $$
DECLARE
  pVendid ALIAS FOR $1;
  pPeriodid ALIAS FOR $2;
  _value NUMERIC;

BEGIN

  SELECT SUM( CASE WHEN (apopen_doctype='C') THEN ((apopen_amount - apopen_paid) * -1)
                   ELSE (apopen_amount - apopen_paid)
              END )  INTO _value
  FROM apopen
  WHERE ( (apopen_open)
   AND (apopen_vend_id=pVendid)
   AND (apopen_duedate BETWEEN findPeriodStart(pPeriodid) AND findPeriodEnd(pPeriodid) ) );

  IF (_value IS NULL) THEN
    _value := 0;
  END IF;

  RETURN _value;

END;
$$ LANGUAGE 'plpgsql';
