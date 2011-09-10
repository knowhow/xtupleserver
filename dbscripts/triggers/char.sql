CREATE OR REPLACE FUNCTION _charBeforeTrigger () RETURNS TRIGGER AS $$
BEGIN
  IF (NOT checkPrivilege('MaintainCharacteristics')) THEN
    RAISE EXCEPTION 'You do not have privileges to maintain Characteristics.';
  END IF;

  IF (NOT NEW.char_items       AND NOT NEW.char_customers  AND
      NOT NEW.char_lotserial   AND NOT NEW.char_addresses  AND
      NOT NEW.char_crmaccounts AND NOT NEW.char_contacts   AND
      NOT NEW.char_opportunity AND NOT NEW.char_employees  AND
      NOT NEW.char_incidents
     ) THEN
    RAISE EXCEPTION 'You must apply this Characteristic to at least one type of application object.';
  END IF;

  RETURN NEW;
END;
$$	 LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'charBeforeTrigger');
CREATE TRIGGER charBeforeTrigger BEFORE INSERT OR UPDATE ON char FOR EACH ROW EXECUTE PROCEDURE _charBeforeTrigger();
