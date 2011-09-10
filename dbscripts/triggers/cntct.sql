-- Before trigger
CREATE OR REPLACE FUNCTION _cntctTrigger() RETURNS "trigger" AS $$
BEGIN

  NEW.cntct_name := formatCntctName(NULL, NEW.cntct_first_name, NEW.cntct_middle, NEW.cntct_last_name, NEW.cntct_suffix);
  NEW.cntct_email := lower(NEW.cntct_email);
  
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'cntctTrigger');
CREATE TRIGGER cntcttrigger
  BEFORE INSERT OR UPDATE
  ON cntct
  FOR EACH ROW
  EXECUTE PROCEDURE _cntctTrigger();

-- After trigger
CREATE OR REPLACE FUNCTION _cntctTriggerAfter() RETURNS "trigger" AS $$
DECLARE
  _cntctemlid INTEGER;
  _rows INTEGER;
BEGIN
  IF (TG_OP = 'INSERT') THEN
    IF(length(coalesce(NEW.cntct_email,'')) > 0) THEN
      INSERT INTO cntcteml (
        cntcteml_cntct_id, cntcteml_primary, cntcteml_email )
      VALUES (
        NEW.cntct_id, true, NEW.cntct_email );
    END IF;
  ELSIF (TG_OP = 'UPDATE') THEN
    IF (OLD.cntct_email != NEW.cntct_email) THEN
      SELECT cntcteml_id INTO _cntctemlid
      FROM cntcteml
      WHERE ((cntcteml_cntct_id=NEW.cntct_id)
        AND (cntcteml_email=NEW.cntct_email));

      GET DIAGNOSTICS _rows = ROW_COUNT;
      IF (_rows = 0) THEN
        UPDATE cntcteml SET
          cntcteml_primary=false
        WHERE ((cntcteml_cntct_id=NEW.cntct_id)
         AND (cntcteml_primary=true));
       
        INSERT INTO cntcteml (
          cntcteml_cntct_id, cntcteml_primary, cntcteml_email )
        VALUES (
          NEW.cntct_id, true, NEW.cntct_email ); 
      ELSE
        UPDATE cntcteml SET
          cntcteml_primary=false
        WHERE ((cntcteml_cntct_id=NEW.cntct_id)
         AND (cntcteml_primary=true));

        UPDATE cntcteml SET
          cntcteml_primary=true
        WHERE (cntcteml_id=_cntctemlid);
      END IF;
    END IF;
  ELSIF (TG_OP = 'DELETE') THEN
      DELETE FROM cntcteml WHERE cntcteml_cntct_id=OLD.cntct_id;
      
      RETURN OLD;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'cntctTriggerAfter');
CREATE TRIGGER cntcttriggerafter
  AFTER INSERT OR UPDATE OR DELETE
  ON cntct
  FOR EACH ROW
  EXECUTE PROCEDURE _cntctTriggerAfter();

