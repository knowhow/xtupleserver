CREATE OR REPLACE FUNCTION _empBeforeTrigger () RETURNS TRIGGER AS $$
BEGIN

  IF NOT (checkPrivilege('MaintainEmployees')) THEN
    RAISE EXCEPTION 'You do not have privileges to maintain Employees.';
  END IF;

  IF (TG_OP IN ('INSERT', 'UPDATE')) THEN
    IF (NEW.emp_code IS NULL) THEN
      RAISE EXCEPTION 'You must supply a valid Employee Code.';
    END IF;

    IF (NEW.emp_number IS NULL) THEN
      RAISE EXCEPTION 'You must supply a valid Employee Number.';
    END IF;

    IF (NEW.emp_id = NEW.emp_mgr_emp_id) THEN
      RAISE EXCEPTION 'An Employee may not be his or her own Manager.';
    END IF;

    -- ERROR:  cannot use column references in default expression
    IF (NEW.emp_name IS NULL) THEN
      NEW.emp_name = COALESCE(formatCntctName(emp_cntct_id), emp_number);
    END IF;

    NEW.emp_code := UPPER(NEW.emp_code);

    -- deprecated column emp_username
    IF (TG_OP = 'UPDATE' AND
        LOWER(NEW.emp_username) != LOWER(NEW.emp_code) AND
        EXISTS(SELECT 1
                 FROM crmacct
                WHERE crmacct_emp_id = NEW.emp_id
                  AND crmacct_usr_username IS NOT NULL)) THEN
      NEW.emp_username = LOWER(NEW.emp_code);
    END IF;

  ELSIF (TG_OP = 'DELETE') THEN
    UPDATE crmacct SET crmacct_emp_id = NULL
     WHERE crmacct_emp_id = OLD.emp_id;

    UPDATE salesrep SET salesrep_emp_id = NULL
     WHERE salesrep_emp_id = OLD.emp_id;

    RETURN OLD;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'empBeforeTrigger');
CREATE TRIGGER empBeforeTrigger BEFORE INSERT OR UPDATE OR DELETE ON emp
       FOR EACH ROW EXECUTE PROCEDURE _empBeforeTrigger();

CREATE OR REPLACE FUNCTION _empAfterTrigger () RETURNS TRIGGER AS $$
DECLARE
  _cmnttypeid     INTEGER;
  _newcrmacctname TEXT;

BEGIN

  IF (TG_OP = 'INSERT') THEN
    -- http://www.postgresql.org/docs/current/static/plpgsql-control-structures.html#PLPGSQL-UPSERT-EXAMPLE
    LOOP
      UPDATE crmacct SET crmacct_emp_id=NEW.emp_id,
                         crmacct_name=NEW.emp_name
       WHERE crmacct_number=NEW.emp_code;
      IF (FOUND) THEN
        EXIT;
      END IF;
      BEGIN
        INSERT INTO crmacct(crmacct_number,  crmacct_name,    crmacct_active,
                            crmacct_type,    crmacct_emp_id,  crmacct_cntct_id_1
                  ) VALUES (NEW.emp_code,    NEW.emp_name,    NEW.emp_active, 
                            'I',             NEW.emp_id,      NEW.emp_cntct_id);
        EXIT;
      EXCEPTION WHEN unique_violation THEN
            -- do nothing, and loop to try the UPDATE again
      END;
    END LOOP;

    /* TODO: default characteristic assignments based on empgrp? */

  ELSIF (TG_OP = 'UPDATE') THEN
    UPDATE crmacct SET crmacct_number = NEW.emp_code
    WHERE ((crmacct_emp_id=NEW.emp_id)
      AND  (crmacct_number!=NEW.emp_code));

    UPDATE crmacct SET crmacct_name = NEW.emp_name
    WHERE ((crmacct_emp_id=NEW.emp_id)
      AND  (crmacct_name!=NEW.emp_name));
  END IF;

  IF (fetchMetricBool('EmployeeChangeLog')) THEN
    SELECT cmnttype_id INTO _cmnttypeid
      FROM cmnttype
     WHERE (cmnttype_name='ChangeLog');

    IF (_cmnttypeid IS NOT NULL) THEN
      IF (TG_OP = 'INSERT') THEN
        PERFORM postComment(_cmnttypeid, 'EMP', NEW.emp_id, 'Created');

      ELSIF (TG_OP = 'DELETE') THEN
	PERFORM postComment(_cmnttypeid, 'EMP', OLD.emp_id,
                            ('Deleted "' || OLD.emp_code || '"'));

      ELSIF (TG_OP = 'UPDATE') THEN

        IF (OLD.emp_number <> NEW.emp_number) THEN
          PERFORM postComment(_cmnttypeid, 'EMP', NEW.emp_id,
                              ('Number Changed from "' || OLD.emp_number ||
                               '" to "' || NEW.emp_number || '"'));
        END IF;

        IF (OLD.emp_code <> NEW.emp_code) THEN
          PERFORM postComment(_cmnttypeid, 'EMP', NEW.emp_id,
                              ('Code Changed from "' || OLD.emp_code ||
                               '" to "' || NEW.emp_code || '"'));
        END IF;

        IF (OLD.emp_active <> NEW.emp_active) THEN
          PERFORM postComment(_cmnttypeid, 'EMP', NEW.emp_id,
                              CASE WHEN NEW.emp_active THEN 'Activated'
                                   ELSE 'Deactivated' END);
        END IF;

        IF (COALESCE(OLD.emp_dept_id, -1) <> COALESCE(NEW.emp_dept_id, -1)) THEN
          PERFORM postComment(_cmnttypeid, 'EMP', NEW.emp_id,
                              ('Department Changed from "' ||
                               COALESCE((SELECT dept_number FROM dept
                                          WHERE dept_id=OLD.emp_dept_id), '')
                               || '" to "' ||
                               COALESCE((SELECT dept_number FROM dept
                                          WHERE dept_id=NEW.emp_dept_id), '') || '"'));
        END IF;

        IF (COALESCE(OLD.emp_shift_id, -1) <> COALESCE(NEW.emp_shift_id, -1)) THEN
          PERFORM postComment(_cmnttypeid, 'EMP', NEW.emp_id,
                              ('Shift Changed from "' ||
                               COALESCE((SELECT shift_number FROM shift
                                          WHERE shift_id=OLD.emp_shift_id), '')
                               || '" to "' ||
                               COALESCE((SELECT shift_number FROM shift
                                          WHERE shift_id=NEW.emp_shift_id), '') || '"'));
        END IF;

      END IF;
    END IF;
  END IF;

  IF (TG_OP = 'DELETE') THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'empAfterTrigger');
CREATE TRIGGER empAfterTrigger AFTER INSERT OR UPDATE OR DELETE ON emp
       FOR EACH ROW EXECUTE PROCEDURE _empAfterTrigger();
