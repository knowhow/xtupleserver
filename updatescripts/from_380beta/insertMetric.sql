BEGIN;

CREATE OR REPLACE FUNCTION insertCreditTaxDiscount() RETURNS INTEGER AS $$
DECLARE
  _result INTEGER;

BEGIN
  SELECT metric_id INTO _result
  FROM metric
  WHERE metric_name='CreditTaxDiscount';

  IF (NOT FOUND) THEN
    INSERT INTO metric (metric_name, metric_value) values ('CreditTaxDiscount', 't');
  END IF;

  RETURN 0;
END;
$$ LANGUAGE 'plpgsql';

SELECT insertCreditTaxDiscount();
DROP FUNCTION insertCreditTaxDiscount();

COMMIT;

