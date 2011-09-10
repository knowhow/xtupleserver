CREATE OR REPLACE FUNCTION _urlTrigger () RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.url_source = 'INCDT') THEN
    UPDATE incdt SET incdt_updated = now() WHERE incdt_id = NEW.url_source_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropifexists('TRIGGER' ,'urlTrigger');
CREATE TRIGGER urlTrigger AFTER INSERT OR UPDATE ON url FOR EACH ROW EXECUTE PROCEDURE _urlTrigger();
