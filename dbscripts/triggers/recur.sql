CREATE OR REPLACE FUNCTION _recurAfterTrigger () RETURNS TRIGGER AS $$
DECLARE
  _parentid   INTEGER;
  _parenttype TEXT;
BEGIN
  IF (TG_OP = 'DELETE') THEN
    IF (UPPER(OLD.recur_parent_type) = 'TODO') THEN
      UPDATE todoitem SET todoitem_recurring_todoitem_id=NULL
       WHERE (todoitem_recurring_todoitem_id=OLD.recur_parent_id);
    END IF;

    RETURN OLD;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'todoitemTrigger');
CREATE TRIGGER todoitemTrigger AFTER DELETE ON recur FOR EACH ROW EXECUTE PROCEDURE _recurAfterTrigger();
