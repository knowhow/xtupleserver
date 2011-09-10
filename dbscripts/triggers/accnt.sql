CREATE OR REPLACE FUNCTION _accntTrigger () RETURNS TRIGGER AS $$
DECLARE
  ffSub BOOLEAN;
  ffProfit BOOLEAN;
  result INTEGER;
BEGIN
  SELECT (metric_value='t')
    INTO ffSub
    FROM metric
   WHERE(metric_name='GLFFSubaccounts')
   LIMIT 1;
  ffSub := COALESCE(ffSub, false);

  SELECT (metric_value='t')
    INTO ffProfit
    FROM metric
   WHERE(metric_name='GLFFProfitCenters')
   LIMIT 1;
  ffProfit := COALESCE(ffSub, false);

  IF (NEW.accnt_sub IS NOT NULL AND ffSub = false) THEN
    SELECT subaccnt_id
      INTO result
      FROM subaccnt
     WHERE(subaccnt_number=NEW.accnt_sub)
     LIMIT 1;
    IF (NOT FOUND) THEN
      RAISE EXCEPTION 'You must supply a valid Sub Account Number.';
    END IF;
  END IF;

  IF (NEW.accnt_profit IS NOT NULL AND ffProfit = false) THEN
    SELECT prftcntr_id
      INTO result
      FROM prftcntr
     WHERE(prftcntr_number=NEW.accnt_profit)
     LIMIT 1;
    IF (NOT FOUND) THEN
      RAISE EXCEPTION 'You must supply a valid Profit Center Number.';
    END IF;
  END IF;

  IF (TG_OP = 'UPDATE') THEN
    IF ((NEW.accnt_type != OLD.accnt_type) AND
        (SELECT (count(*) > 0) FROM gltrans WHERE (gltrans_accnt_id=NEW.accnt_id))) THEN
      RAISE EXCEPTION 'You may not change the account type of an account that has transaction history';
    END IF;
  END IF;

  NEW.accnt_name := formatGlAccount(NEW.accnt_company, NEW.accnt_profit, NEW.accnt_number, NEW.accnt_sub);

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'accntTrigger');
CREATE TRIGGER accntTrigger BEFORE INSERT OR UPDATE ON accnt FOR EACH ROW EXECUTE PROCEDURE _accntTrigger();

CREATE OR REPLACE FUNCTION _accntUniqueTrigger () RETURNS TRIGGER AS $$
DECLARE
BEGIN
  -- This trigger is to protect against id collision on inherited tables since there is no way 
  -- to enforce that with regular constraints.  It should be applied to accnt and any table that 
  -- inherits accnt.
  IF (SELECT (count(accnt_id) > 0) FROM accnt WHERE (accnt_id = NEW.accnt_id)) THEN
    RAISE EXCEPTION 'Can not create record on account with duplicate key %.', NEW.accnt_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'accntUniqueTrigger');
CREATE TRIGGER accntUniqueTrigger BEFORE INSERT ON accnt FOR EACH ROW EXECUTE PROCEDURE _accntUniqueTrigger();


