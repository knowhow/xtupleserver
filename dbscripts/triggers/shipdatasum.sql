CREATE OR REPLACE FUNCTION _shipdatasumtrigger() RETURNS TRIGGER AS '
BEGIN

  IF (LENGTH(TRIM(NEW.shipdatasum_shiphead_number)) = 0) THEN
    NEW.shipdatasum_shiphead_number = NULL;
  END IF;

  RETURN NEW;

END;
'
  LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'shipdatasumtrigger');
CREATE TRIGGER shipdatasumtrigger BEFORE INSERT OR UPDATE ON shipdatasum FOR EACH ROW EXECUTE PROCEDURE _shipdatasumtrigger();
