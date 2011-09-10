CREATE OR REPLACE FUNCTION _salesrepBeforeTrigger () RETURNS TRIGGER AS $$
BEGIN

  IF NOT (checkPrivilege('MaintainSalesReps')) THEN
    RAISE EXCEPTION 'You do not have privileges to maintain Sales Reps.';
  END IF;

  IF (TG_OP IN ('INSERT', 'UPDATE')) THEN
    IF (NEW.salesrep_number IS NULL) THEN
      RAISE EXCEPTION 'You must supply a valid Sales Rep Number.';
    END IF;

    IF (NEW.salesrep_commission IS NULL) THEN
      RAISE EXCEPTION 'You must supply a Commission Rate for this Sales Rep.';
    END IF;

    NEW.salesrep_number = UPPER(NEW.salesrep_number);

    -- deprecated column salesrep_emp_id
    -- TODO: will this prevent breaking the crmacct-emp relationship?
    IF (TG_OP = 'UPDATE') THEN
      SELECT crmacct_emp_id INTO NEW.salesrep_emp_id
        FROM crmacct
       WHERE crmacct_salesrep_id = NEW.salesrep_id;
    END IF;

  ELSIF (TG_OP = 'DELETE') THEN
    UPDATE crmacct SET crmacct_salesrep_id = NULL
     WHERE crmacct_salesrep_id = OLD.salesrep_id;
    RETURN OLD;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'salesrepBeforeTrigger');
CREATE TRIGGER salesrepBeforeTrigger BEFORE INSERT OR UPDATE OR DELETE ON salesrep
       FOR EACH ROW EXECUTE PROCEDURE _salesrepBeforeTrigger();

CREATE OR REPLACE FUNCTION _salesrepAfterTrigger() RETURNS TRIGGER AS $$
DECLARE
  _cmnttypeid INTEGER;

BEGIN

  IF (TG_OP = 'INSERT') THEN
    -- http://www.postgresql.org/docs/current/static/plpgsql-control-structures.html#PLPGSQL-UPSERT-EXAMPLE
    LOOP
      UPDATE crmacct SET crmacct_salesrep_id=NEW.salesrep_id,
                         crmacct_name=NEW.salesrep_name
      WHERE crmacct_number=NEW.salesrep_number;
      IF (FOUND) THEN
        EXIT;
      END IF;
      BEGIN
        INSERT INTO crmacct(crmacct_number,      crmacct_name,      crmacct_active,
                            crmacct_type,        crmacct_salesrep_id
                  ) VALUES (NEW.salesrep_number, NEW.salesrep_name, NEW.salesrep_active,
                            'I',                 NEW.salesrep_id);
        EXIT;
      EXCEPTION WHEN unique_violation THEN
            -- do nothing, and loop to try the UPDATE again
      END;
    END LOOP;

    -- TODO: default characteristic assignments?

  ELSIF (TG_OP = 'UPDATE') THEN
    UPDATE crmacct SET crmacct_number = NEW.salesrep_number
    WHERE ((crmacct_salesrep_id=NEW.salesrep_id)
      AND  (crmacct_number!=NEW.salesrep_number));

    UPDATE crmacct SET crmacct_name = NEW.salesrep_name
    WHERE ((crmacct_salesrep_id=NEW.salesrep_id)
      AND  (crmacct_name!=NEW.salesrep_name));
  END IF;

  IF (fetchMetricBool('SalesRepChangeLog')) THEN
    SELECT cmnttype_id INTO _cmnttypeid
      FROM cmnttype
     WHERE (cmnttype_name='ChangeLog');

    IF (_cmnttypeid IS NOT NULL) THEN
      IF (TG_OP = 'INSERT') THEN
        PERFORM postComment(_cmnttypeid, 'SR', NEW.salesrep_id, 'Created');

      ELSIF (TG_OP = 'DELETE') THEN
        PERFORM postComment(_cmnttypeid, 'SR', OLD.salesrep_id,
                            'Deleted "' || OLD.salesrep_number || '"');

      ELSIF (TG_OP = 'UPDATE') THEN
        IF (OLD.salesrep_active <> NEW.salesrep_active) THEN
          PERFORM postComment(_cmnttypeid, 'SR', NEW.salesrep_id,
                              CASE WHEN NEW.salesrep_active THEN 'Activated'
                                   ELSE 'Deactivated' END);
        END IF;

        IF (OLD.salesrep_number <> NEW.salesrep_number) THEN
          PERFORM postComment(_cmnttypeid, 'SR', NEW.salesrep_id,
                              'Number changed from "' || OLD.salesrep_number ||
                              '" to "' || NEW.salesrep_number || '"');
        END IF;

        IF (OLD.salesrep_name <> NEW.salesrep_name) THEN
          PERFORM postComment(_cmnttypeid, 'SR', NEW.salesrep_id,
                              'Name changed from "' || OLD.salesrep_name ||
                              '" to "' || NEW.salesrep_name || '"');
        END IF;

        IF (OLD.salesrep_commission <> NEW.salesrep_commission) THEN
          PERFORM postComment(_cmnttypeid, 'SR', NEW.salesrep_id,
                              'Commission changed from "' || OLD.salesrep_commission ||
                              '" to "' || NEW.salesrep_commission || '"');
        END IF;

        IF (OLD.salesrep_method <> NEW.salesrep_method) THEN
          PERFORM postComment(_cmnttypeid, 'SR', NEW.salesrep_id,
                              'Method changed from "' || OLD.salesrep_method ||
                              '" to "' || NEW.salesrep_method || '"');
        END IF;

      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'salesrepAfterTrigger');
CREATE TRIGGER salesrepAfterTrigger AFTER INSERT OR UPDATE OR DELETE ON salesrep
       FOR EACH ROW EXECUTE PROCEDURE _salesrepAfterTrigger();
