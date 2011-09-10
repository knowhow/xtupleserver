
CREATE OR REPLACE FUNCTION _packBeforeTrigger() RETURNS TRIGGER AS $$
DECLARE
  _cmnttypeid INTEGER;
BEGIN
  SELECT cmnttype_id INTO _cmnttypeid
    FROM cmnttype
    WHERE (cmnttype_name='ChangeLog');
  IF (FOUND) THEN
    IF ((TG_OP = 'INSERT') AND (NEW.pack_head_id) IS NOT NULL)THEN
      PERFORM postComment(_cmnttypeid, 'S', NEW.pack_head_id, 'Added to Packing List Batch');
    END IF;
  END IF;
  IF ((TG_OP = 'INSERT') OR (TG_OP = 'UPDATE')) THEN
    IF (NEW.pack_shiphead_id IS NOT NULL
	 AND NEW.pack_shiphead_id NOT IN (SELECT shiphead_id
			       FROM shiphead
			       WHERE (shiphead_order_id=NEW.pack_head_id)
				 AND (shiphead_order_type=NEW.pack_head_type))) THEN
      RAISE EXCEPTION 'Shipment does not exist for % id %',
		      NEW.pack_head_type, NEW.pack_head_id;
      RETURN OLD;
    END IF;

    IF (NEW.pack_head_type = 'SO'
	AND NEW.pack_head_id   IN (SELECT cohead_id FROM cohead)) THEN
      RETURN NEW;

    ELSEIF (NEW.pack_head_type = 'TO') THEN
      IF (NOT fetchMetricBool('MultiWhs')) THEN
	RAISE EXCEPTION 'Transfer Orders are not supported by this version of the application';
      ELSEIF (NEW.pack_head_id IN (SELECT tohead_id FROM tohead)) THEN
	RETURN NEW;
      END IF;
    END IF;

    RAISE EXCEPTION '% with id % does not exist',
		    NEW.pack_head_type, NEW.pack_head_id;
    RETURN OLD;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER packBeforeTrigger ON pack;
CREATE TRIGGER packBeforeTrigger BEFORE INSERT OR UPDATE ON pack FOR EACH ROW EXECUTE PROCEDURE _packBeforeTrigger();
