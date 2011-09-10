CREATE OR REPLACE FUNCTION _addrtrigger() RETURNS "trigger" AS '
  DECLARE
    _uses	INTEGER	:= 0;

  BEGIN
    SELECT count(*) INTO _uses
    FROM cntct
    WHERE ((cntct_addr_id=OLD.addr_id)
      AND   cntct_active);

    IF (TG_OP = ''UPDATE'') THEN
      IF (OLD.addr_active AND NOT NEW.addr_active AND _uses > 0) THEN
	RAISE EXCEPTION ''Cannot inactivate Address with Active Contacts (%)'',
			_uses;
      END IF;
    ELSIF (TG_OP = ''DELETE'') THEN
      IF (_uses > 0) THEN
	RAISE EXCEPTION ''Cannot Delete Address with Active Contacts (%)'',
			_uses;
      END IF;

      UPDATE cntct SET cntct_addr_id = NULL
      WHERE ((cntct_addr_id=OLD.addr_id)
	AND  (NOT cntct_active));

      RETURN OLD;
    END IF;

    RETURN NEW;
  END;
' LANGUAGE 'plpgsql';

DROP TRIGGER addrtrigger ON addr;
CREATE TRIGGER addrtrigger
  BEFORE  -- INSERT OR
	  UPDATE OR DELETE
  ON addr
  FOR EACH ROW
  EXECUTE PROCEDURE _addrtrigger();
