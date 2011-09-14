-- TODO: add special handling for converting prospects <-> customers?
CREATE OR REPLACE FUNCTION _crmacctBeforeTrigger () RETURNS TRIGGER AS $$
BEGIN
  -- disallow reusing crmacct_numbers
  IF (TG_OP IN ('INSERT', 'UPDATE')) THEN

    NEW.crmacct_usr_username := LOWER(TRIM(NEW.crmacct_usr_username));
    IF (NEW.crmacct_usr_username = '') THEN
      NEW.crmacct_usr_username = NULL;
    END IF;

    NEW.crmacct_owner_username := LOWER(TRIM(NEW.crmacct_owner_username));
    IF (COALESCE(NEW.crmacct_owner_username, '') = '') THEN
      NEW.crmacct_owner_username = getEffectiveXtUser();
    END IF;

    IF (NEW.crmacct_competitor_id < 0) THEN
      NEW.crmacct_competitor_id := NULL;
    END IF;
    IF (NEW.crmacct_partner_id < 0) THEN
      NEW.crmacct_partner_id := NULL;
    END IF;

    NEW.crmacct_number = UPPER(NEW.crmacct_number);

    IF (TG_OP = 'UPDATE') THEN
      -- TODO: why not ALTER USER OLD.crmacct_number RENAME TO LOWER(NEW.crmacct_number)?
      IF (NEW.crmacct_number != UPPER(OLD.crmacct_number) AND
          NEW.crmacct_usr_username IS NOT NULL            AND
          UPPER(NEW.crmacct_usr_username) != NEW.crmacct_number) THEN
        RAISE EXCEPTION 'The CRM Account % is associated with a system User so the number cannot be changed.',
                        NEW.crmacct_number;
      END IF;
    END IF;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER crmacctBeforeTrigger ON crmacct;
CREATE TRIGGER crmacctBeforeTrigger BEFORE INSERT OR UPDATE ON crmacct FOR EACH ROW EXECUTE PROCEDURE _crmacctBeforeTrigger();

CREATE OR REPLACE FUNCTION _crmacctAfterTrigger () RETURNS TRIGGER AS $$
DECLARE
  _cmnttypeid INTEGER;
  _gotpriv    BOOLEAN;

BEGIN
  /* update _number and _name separately to propagate just what changed.
     the priv manipulation allows targeted updates of crmaccount-maintained data
     (note: grantPriv() == false if the user already had the priv, true if this
     call granted the priv).
   */
  IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
    IF (NEW.crmacct_cust_id IS NOT NULL) THEN
      _gotpriv := grantPriv(getEffectiveXtUser(), 'MaintainCustomerMasters');
      UPDATE custinfo SET cust_number = NEW.crmacct_number
      WHERE ((cust_id=NEW.crmacct_cust_id)
        AND  (cust_number!=NEW.crmacct_number));
      UPDATE custinfo SET cust_name = NEW.crmacct_name
      WHERE ((cust_id=NEW.crmacct_cust_id)
        AND  (cust_name!=NEW.crmacct_name));
      IF (_gotpriv) THEN
        PERFORM revokePriv(getEffectiveXtUser(), 'MaintainCustomerMasters');
      END IF;
    END IF;

    IF (NEW.crmacct_emp_id IS NOT NULL) THEN
      _gotpriv := grantPriv(getEffectiveXtUser(), 'MaintainEmployees');
      UPDATE emp SET emp_code = NEW.crmacct_number
      WHERE ((emp_id=NEW.crmacct_emp_id)
        AND  (emp_code!=NEW.crmacct_number));
      UPDATE emp SET emp_name = NEW.crmacct_name
      WHERE ((emp_id=NEW.crmacct_emp_id)
        AND  (emp_name!=NEW.crmacct_name));
      IF (_gotpriv) THEN
        PERFORM revokePriv(getEffectiveXtUser(), 'MaintainEmployees');
      END IF;
    END IF;

    IF (NEW.crmacct_prospect_id IS NOT NULL) THEN
      _gotpriv := grantPriv(getEffectiveXtUser(), 'MaintaiProspectMasters');
      UPDATE prospect SET prospect_number = NEW.crmacct_number
      WHERE ((prospect_id=NEW.crmacct_prospect_id)
        AND  (prospect_number!=NEW.crmacct_number));
      UPDATE prospect SET prospect_name = NEW.crmacct_name
      WHERE ((prospect_id=NEW.crmacct_prospect_id)
        AND  (prospect_name!=NEW.crmacct_name));
      IF (_gotpriv) THEN
        PERFORM revokePriv(getEffectiveXtUser(), 'MaintainProspectMasters');
      END IF;
    END IF;

    IF (NEW.crmacct_salesrep_id IS NOT NULL) THEN
      _gotpriv := grantPriv(getEffectiveXtUser(), 'MaintainSalesReps');
      UPDATE salesrep SET salesrep_number = NEW.crmacct_number
      WHERE ((salesrep_id=NEW.crmacct_salesrep_id)
        AND  (salesrep_number!=NEW.crmacct_number));
      UPDATE salesrep SET salesrep_name = NEW.crmacct_name
      WHERE ((salesrep_id=NEW.crmacct_salesrep_id)
        AND  (salesrep_name!=NEW.crmacct_name));
      IF (_gotpriv) THEN
        PERFORM revokePriv(getEffectiveXtUser(), 'MaintainSalesReps');
      END IF;
    END IF;

    IF (NEW.crmacct_taxauth_id IS NOT NULL) THEN
      _gotpriv := grantPriv(getEffectiveXtUser(), 'MaintainTaxAuthorities');
      UPDATE taxauth SET taxauth_code = NEW.crmacct_number
      WHERE ((taxauth_id=NEW.crmacct_taxauth_id)
        AND  (taxauth_code!=NEW.crmacct_number));
      UPDATE taxauth SET taxauth_name = NEW.crmacct_name
      WHERE ((taxauth_id=NEW.crmacct_taxauth_id)
        AND  (taxauth_name!=NEW.crmacct_name));
      IF (_gotpriv) THEN
        PERFORM revokePriv(getEffectiveXtUser(), 'MaintainTaxAuthorities');
      END IF;
    END IF;

    IF (NEW.crmacct_vend_id IS NOT NULL) THEN
      _gotpriv := grantPriv(getEffectiveXtUser(), 'MaintainVendors');
      UPDATE vendinfo SET vend_number = NEW.crmacct_number
      WHERE ((vend_id=NEW.crmacct_vend_id)
        AND  (vend_number!=NEW.crmacct_number));
      UPDATE vendinfo SET vend_name = NEW.crmacct_name
      WHERE ((vend_id=NEW.crmacct_vend_id)
        AND  (vend_name!=NEW.crmacct_name));
      IF (_gotpriv) THEN
        PERFORM revokePriv(getEffectiveXtUser(), 'MaintainVendors');
      END IF;
    END IF;

    -- Link Primary and Secondary Contacts to this Account if they are not already
    IF (NEW.crmacct_cntct_id_1 IS NOT NULL) THEN
      _gotpriv := grantPriv(getEffectiveXtUser(), 'MaintainAllContacts');
      UPDATE cntct SET cntct_crmacct_id = NEW.crmacct_id
       WHERE cntct_id=NEW.crmacct_cntct_id_1;
      IF (_gotpriv) THEN
        PERFORM revokePriv(getEffectiveXtUser(), 'MaintainAllContacts');
      END IF;
    END IF;

    IF (NEW.crmacct_cntct_id_2 IS NOT NULL) THEN
      _gotpriv := grantPriv(getEffectiveXtUser(), 'MaintainAllContacts');
      UPDATE cntct SET cntct_crmacct_id = NEW.crmacct_id
       WHERE cntct_id=NEW.crmacct_cntct_id_2;
      IF (_gotpriv) THEN
        PERFORM revokePriv(getEffectiveXtUser(), 'MaintainAllContacts');
      END IF;
    END IF;

    -- cannot have fkey references to system catalogs so enforce them here
    IF (NEW.crmacct_usr_username IS NOT NULL) THEN
      IF (NOT EXISTS(SELECT usename
                       FROM pg_user
                      WHERE usename=NEW.crmacct_usr_username)) THEN
        RAISE EXCEPTION 'User % does not exist so this CRM Account Number is invalid.',
                        NEW.crmacct_usr_username;
      END IF;
      IF (TG_OP = 'UPDATE') THEN
        -- reminder: this evaluates to false if either is NULL
        IF (NEW.crmacct_usr_username != OLD.crmacct_usr_username) THEN
          RAISE EXCEPTION 'Cannot change the user name for %',
                          OLD.crmacct_usr_username;
        END IF;
      END IF;
      UPDATE usrpref SET usrpref_value = NEW.crmacct_name
      WHERE ((usrpref_username=NEW.crmacct_usr_username)
        AND  (usrpref_name='propername')
        AND  (usrpref_value!=NEW.crmacct_name));
    END IF;

    IF (NEW.crmacct_owner_username IS NOT NULL) THEN
      IF (NOT EXISTS(SELECT usename
                       FROM pg_user
                      WHERE usename=NEW.crmacct_owner_username)) THEN
        RAISE EXCEPTION 'User % does not exist so this CRM Account Owner is invalid.',
                        NEW.crmacct_owner_username;
      END IF;
    END IF;

  ELSIF (TG_OP = 'DELETE') THEN
    IF (OLD.crmacct_cust_id IS NOT NULL) THEN
      RAISE EXCEPTION '[xtuple: deleteCrmAccount, -1]';
    END IF;

    IF (OLD.crmacct_emp_id IS NOT NULL) THEN
      RAISE EXCEPTION '[xtuple: deleteCrmAccount, -7]';
    END IF;

    IF (OLD.crmacct_prospect_id IS NOT NULL) THEN
      RAISE EXCEPTION '[xtuple: deleteCrmAccount, -3]';
    END IF;

    DELETE FROM salesrep WHERE salesrep_id  = OLD.crmacct_salesrep_id;
    IF (OLD.crmacct_salesrep_id IS NOT NULL) THEN
      RAISE EXCEPTION '[xtuple: deleteCrmAccount, -6]';
    END IF;

    IF (OLD.crmacct_taxauth_id IS NOT NULL) THEN
      RAISE EXCEPTION '[xtuple: deleteCrmAccount, -5]';
    END IF;

    IF (EXISTS(SELECT usename
                 FROM pg_user
                WHERE usename=OLD.crmacct_usr_username)) THEN
      RAISE EXCEPTION '[xtuple: deleteCrmAccount, -8]';
    END IF;

    IF (OLD.crmacct_vend_id IS NOT NULL) THEN
      RAISE EXCEPTION '[xtuple: deleteCrmAccount, -2]';
    END IF;

    DELETE FROM imageass
     WHERE (imageass_source_id=OLD.crmacct_id) AND (imageass_source='CRMA');
    DELETE FROM url
     WHERE (url_source_id=OLD.crmacct_id)      AND (url_source='CRMA');

  END IF;

  SELECT cmnttype_id INTO _cmnttypeid
    FROM cmnttype
   WHERE (cmnttype_name='ChangeLog');
  IF (_cmnttypeid IS NOT NULL) THEN
    IF (TG_OP = 'INSERT') THEN
      PERFORM postComment(_cmnttypeid, 'CRMA', NEW.crmacct_id,
                          ('Created by ' || getEffectiveXtUser()));

    ELSIF (TG_OP = 'DELETE') THEN
      PERFORM postComment(_cmnttypeid, 'CRMA', OLD.crmacct_id,
                          'Deleted "' || OLD.crmacct_number || '"');
    END IF;
  END IF;

  IF (TG_OP = 'DELETE') THEN
    RETURN OLD;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER crmacctAfterTrigger ON crmacct;
CREATE TRIGGER crmacctAfterTrigger AFTER INSERT OR UPDATE OR DELETE ON crmacct FOR EACH ROW EXECUTE PROCEDURE _crmacctAfterTrigger();
