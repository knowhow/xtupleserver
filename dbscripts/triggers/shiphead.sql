CREATE OR REPLACE FUNCTION _shipheadBeforeTrigger () RETURNS TRIGGER AS '
BEGIN
  IF ((TG_OP = ''INSERT'') OR (TG_OP = ''UPDATE'')) THEN

    IF (NEW.shiphead_order_type = ''SO''
	AND NEW.shiphead_order_id   IN (SELECT cohead_id FROM cohead)) THEN
      RETURN NEW;

    ELSEIF (NEW.shiphead_order_type = ''TO''
	AND NEW.shiphead_order_id   IN (SELECT tohead_id FROM tohead)) THEN
      RETURN NEW;

    END IF;

    RAISE EXCEPTION ''% with id % does not exist'',
		    NEW.shiphead_order_type, NEW.shiphead_order_id;
    RETURN OLD;

  END IF;

  RETURN NEW;
END;
' LANGUAGE 'plpgsql';

SELECT dropifexists('trigger', 'shipheadbeforetrigger');
CREATE TRIGGER shipheadBeforeTrigger BEFORE INSERT OR UPDATE ON shiphead FOR EACH ROW EXECUTE PROCEDURE _shipheadBeforeTrigger();
