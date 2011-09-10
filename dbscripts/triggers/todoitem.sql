CREATE OR REPLACE FUNCTION _todoitemTrigger () RETURNS TRIGGER AS $$
DECLARE
  _recurid     INTEGER;
  _newparentid INTEGER;
BEGIN
  IF (TG_OP = 'DELETE') THEN
    SELECT recur_id INTO _recurid
      FROM recur
     WHERE ((recur_parent_id=OLD.todoitem_id)
       AND  (recur_parent_type='TODO'));

    IF (_recurid IS NOT NULL) THEN
      RAISE DEBUG 'recur_id for deleted todoitem = %', _recurid;

      SELECT todoitem_id INTO _newparentid
        FROM todoitem
       WHERE ((todoitem_recurring_todoitem_id=OLD.todoitem_id)
          AND (todoitem_id!=OLD.todoitem_id))
       ORDER BY todoitem_due_date
       LIMIT 1;

      RAISE DEBUG '_newparentid for deleted todoitem = %', COALESCE(_newparentid, NULL);

      -- client is responsible for warning about deleting a recurring todoitem
      IF (_newparentid IS NULL) THEN
        DELETE FROM recur WHERE recur_id=_recurid;
      ELSE
        UPDATE recur SET recur_parent_id=_newparentid
         WHERE recur_id=_recurid;

        UPDATE todoitem SET todoitem_recurring_todoitem_id=_newparentid
         WHERE todoitem_recurring_todoitem_id=OLD.todoitem_id
           AND todoitem_id != OLD.todoitem_id;

        RAISE DEBUG 'reparented recurrence';
      END IF;
    END IF;

    DELETE FROM alarm
     WHERE ((alarm_source='TODO')
        AND (alarm_source_id=OLD.todoitem_id));

    RETURN OLD;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'todoitemTrigger');
CREATE TRIGGER todoitemTrigger BEFORE DELETE ON todoitem FOR EACH ROW EXECUTE PROCEDURE _todoitemTrigger();
