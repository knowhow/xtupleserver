CREATE OR REPLACE FUNCTION _taxauthBeforeTrigger() RETURNS TRIGGER AS $$
BEGIN

  IF (NOT checkPrivilege('MaintainTaxAuthorities')) THEN
    RAISE EXCEPTION 'You do not have privileges to maintain Tax Authorities.';
  END IF;

  IF (TG_OP IN ('INSERT', 'UPDATE')) THEN
    IF (NEW.taxauth_code IS NULL) THEN
      RAISE EXCEPTION 'You must supply a Tax Authority Code.';
    END IF;

  ELSIF (TG_OP = 'DELETE') THEN
    UPDATE crmacct SET crmacct_taxauth_id = NULL
     WHERE crmacct_taxauth_id = OLD.taxauth_id;
    RETURN OLD;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('trigger', 'taxauthBeforeTrigger');
CREATE TRIGGER taxauthBeforeTrigger BEFORE INSERT OR UPDATE OR DELETE ON taxauth
       FOR EACH ROW EXECUTE PROCEDURE _taxauthBeforeTrigger();

CREATE OR REPLACE FUNCTION _taxauthAfterTrigger () RETURNS TRIGGER AS $$
DECLARE
  _cmnttypeid INTEGER;

BEGIN

  IF (TG_OP = 'INSERT') THEN
    -- http://www.postgresql.org/docs/current/static/plpgsql-control-structures.html#PLPGSQL-UPSERT-EXAMPLE
    LOOP
      UPDATE crmacct SET crmacct_taxauth_id=NEW.taxauth_id,
                         crmacct_name=NEW.taxauth_name
       WHERE crmacct_number=NEW.taxauth_code;
      IF (FOUND) THEN
        EXIT;
      END IF;
      BEGIN
        INSERT INTO crmacct(crmacct_number,   crmacct_name,     crmacct_active,
                            crmacct_type,     crmacct_taxauth_id
                  ) VALUES (NEW.taxauth_code, NEW.taxauth_name, TRUE, 
                            'O',              NEW.taxauth_id);
        EXIT;
      EXCEPTION WHEN unique_violation THEN
            -- do nothing, and loop to try the UPDATE again
      END;
    END LOOP;

    /* TODO: default characteristic assignments based on what? */

  ELSIF (TG_OP = 'UPDATE') THEN
    UPDATE crmacct SET crmacct_number = NEW.taxauth_code
    WHERE ((crmacct_taxauth_id=NEW.taxauth_id)
      AND  (crmacct_number!=NEW.taxauth_code));

    UPDATE crmacct SET crmacct_name = NEW.taxauth_name
    WHERE ((crmacct_taxauth_id=NEW.taxauth_id)
      AND  (crmacct_name!=NEW.taxauth_name));

  ELSIF (TG_OP = 'DELETE') THEN
    IF (EXISTS(SELECT checkhead_id
                 FROM checkhead
                WHERE checkhead_recip_id = OLD.taxauth_id
                  AND checkhead_recip_type='T')) THEN
      RAISE EXCEPTION '[xtuple: deleteTaxAuthority, -7]';
    END IF;

  END IF;

  IF (fetchMetricBool('TaxAuthChangeLog')) THEN
    SELECT cmnttype_id INTO _cmnttypeid
      FROM cmnttype
     WHERE (cmnttype_name='ChangeLog');

    IF (_cmnttypeid IS NOT NULL) THEN
      IF (TG_OP = 'INSERT') THEN
        PERFORM postComment(_cmnttypeid, 'TAXAUTH', NEW.taxauth_id, 'Created');

      ELSIF (TG_OP = 'DELETE') THEN
        PERFORM postComment(_cmnttypeid, 'TAXAUTH', OLD.taxauth_id,
                            'Deleted "' || OLD.taxauth_number || '"');

      ELSIF (TG_OP = 'UPDATE') THEN

        IF (OLD.taxauth_code <> NEW.taxauth_code) THEN
          PERFORM postComment(_cmnttypeid, 'TAXAUTH', NEW.taxauth_id,
                              'Code changed from "' || OLD.taxauth_code ||
                              '" to "' || NEW.taxauth_code || '"');
        END IF;

        IF (OLD.taxauth_name <> NEW.taxauth_name) THEN
          PERFORM postComment(_cmnttypeid, 'TAXAUTH', NEW.taxauth_id,
                              'Name changed from "' || OLD.taxauth_name ||
                              '" to "' || NEW.taxauth_name || '"');
        END IF;

        IF (OLD.taxauth_extref <> NEW.taxauth_extref) THEN
          PERFORM postComment(_cmnttypeid, 'TAXAUTH', NEW.taxauth_id,
                              'External Ref. changed from "' || OLD.taxauth_extref ||
                              '" to "' || NEW.taxauth_extref || '"');
        END IF;

        IF (OLD.taxauth_addr_id <> NEW.taxauth_addr_id) THEN
          PERFORM postComment(_cmnttypeid, 'TAXAUTH', NEW.taxauth_id,
                              'Address changed from ' || formatAddr(OLD.taxauth_addr_id)
                              || ' to ' || formatAddr(NEW.taxauth_addr_id));
        END IF;

        IF (OLD.taxauth_curr_id <> NEW.taxauth_curr_id) THEN
          PERFORM postComment(_cmnttypeid, 'TAXAUTH', NEW.taxauth_id,
                              'Currency changed from "' ||
                              currConcat(OLD.taxauth_curr_id) || '" to "' ||
                              currConcat(NEW.taxauth_curr_id) || '"');
        END IF;

        IF (OLD.taxauth_county <> NEW.taxauth_county) THEN
          PERFORM postComment(_cmnttypeid, 'TAXAUTH', NEW.taxauth_id,
                              'County changed from "' || OLD.taxauth_county ||
                              '" to "' || NEW.taxauth_county || '"');
        END IF;

        IF (OLD.taxauth_accnt_id <> NEW.taxauth_accnt_id) THEN
          PERFORM postComment(_cmnttypeid, 'TAXAUTH', NEW.taxauth_id,
                              'Account changed from "' ||
                              formatGLAccount(OLD.taxauth_accnt_id) || '" to "' ||
                              formatGLAccount(NEW.taxauth_accnt_id) || '"');
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

SELECT dropIfExists('trigger', 'taxauthAfterTrigger');
CREATE TRIGGER taxauthAfterTrigger AFTER INSERT OR UPDATE OR DELETE ON taxauth
       FOR EACH ROW EXECUTE PROCEDURE _taxauthAfterTrigger();
