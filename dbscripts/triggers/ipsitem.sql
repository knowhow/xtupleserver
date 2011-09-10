CREATE OR REPLACE FUNCTION _ipsitemBeforeTrigger () RETURNS TRIGGER AS '
BEGIN

  --  Checks
  IF NOT (checkPrivilege(''MaintainPricingSchedules'')) THEN
    RAISE EXCEPTION ''You do not have privileges to maintain Price Schedules.'';
  END IF;
  
  IF (TG_OP IN (''INSERT'',''UPDATE'')) THEN
    RETURN NEW;
  ELSE
    RETURN OLD;
  END IF;
END;
' LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'ipsitemBeforeTrigger');
CREATE TRIGGER ipsitemBeforeTrigger BEFORE INSERT OR UPDATE OR DELETE ON ipsitem FOR EACH ROW EXECUTE PROCEDURE _ipsitemBeforeTrigger();
