CREATE OR REPLACE FUNCTION _docassTrigger () RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.docass_source_type = 'INCDT') THEN
    UPDATE incdt SET incdt_updated = now() WHERE incdt_id = NEW.docass_source_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropifexists('TRIGGER' ,'docassTrigger');
CREATE TRIGGER docassTrigger AFTER INSERT OR UPDATE ON docass FOR EACH ROW EXECUTE PROCEDURE _docassTrigger();
