CREATE OR REPLACE FUNCTION _prjtaskTrigger () RETURNS TRIGGER AS $$
DECLARE
  _test text;
  _oldActHrs NUMERIC := 0;
  _oldActExp NUMERIC := 0;
  _cmnttypeid INTEGER;
BEGIN

  --  Checks
  IF (NEW.prjtask_owner_username=getEffectiveXtUser()) THEN
    IF (NOT checkPrivilege('MaintainAllProjects') AND NOT checkPrivilege('MaintainPersonalProjects')) THEN
      RAISE EXCEPTION 'You do not have privileges to maintain Projects.';
    END IF;
  ELSIF (NOT checkPrivilege('MaintainAllProjects')) THEN
    RAISE EXCEPTION 'You do not have privileges to maintain Projects.';
  ELSIF (LENGTH(COALESCE(NEW.prjtask_number,'')) = 0) THEN
    RAISE EXCEPTION 'You must ender a valid number.';
  ELSIF (LENGTH(COALESCE(NEW.prjtask_name,'')) = 0) THEN
    RAISE EXCEPTION 'You must ender a valid name.';	
  END IF;

    SELECT cmnttype_id INTO _cmnttypeid
    FROM cmnttype
    WHERE (cmnttype_name='ChangeLog');
    IF (FOUND) THEN
      IF (TG_OP = 'UPDATE') THEN
        _oldActHrs := OLD.prjtask_hours_actual;
        _oldActExp := OLD.prjtask_exp_actual;
      END IF;

      IF (NEW.prjtask_hours_actual != _oldActHrs) THEN
        PERFORM postComment(_cmnttypeid, 'TA', NEW.prjtask_id, 
          'Actual Hours changed from ' || formatQty(_oldActHrs) || ' to ' || formatQty(NEW.prjtask_hours_actual));
      END IF;

      IF (NEW.prjtask_exp_actual != _oldActExp) THEN
        PERFORM postComment(_cmnttypeid, 'TA', NEW.prjtask_id, 
          'Actual Expense changed from ' || formatQty(_oldActExp) || ' to ' || formatQty(NEW.prjtask_exp_actual));
      END IF;
    END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'prjtaskTrigger');
CREATE TRIGGER prjtaskTrigger BEFORE INSERT OR UPDATE ON prjtask FOR EACH ROW EXECUTE PROCEDURE _prjtaskTrigger();