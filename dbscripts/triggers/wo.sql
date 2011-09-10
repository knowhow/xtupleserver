CREATE OR REPLACE FUNCTION _woTrigger() RETURNS TRIGGER AS '
DECLARE
  _cmnttypeid INTEGER;

BEGIN

  IF ( SELECT (metric_value=''t'')
       FROM metric
       WHERE (metric_name=''WorkOrderChangeLog'') ) THEN
--  Cache the cmnttype_id for ChangeLog
    SELECT cmnttype_id INTO _cmnttypeid
    FROM cmnttype
    WHERE (cmnttype_name=''ChangeLog'');
  ELSE
    _cmnttypeid := -1;
  END IF;

  IF (TG_OP = ''INSERT'') THEN
    INSERT INTO evntlog ( evntlog_evnttime, evntlog_username, evntlog_evnttype_id,
                         evntlog_ordtype, evntlog_ord_id, evntlog_warehous_id, evntlog_number )
    SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,
           ''W'', NEW.wo_id, itemsite_warehous_id, (NEW.wo_number || ''-'' || NEW.wo_subnumber) 
    FROM evntnot, evnttype, itemsite, item
    WHERE ( (evntnot_evnttype_id=evnttype_id)
     AND (evntnot_warehous_id=itemsite_warehous_id)
     AND (itemsite_id=NEW.wo_itemsite_id)
     AND (itemsite_item_id=item_id)
     AND (NEW.wo_duedate <= (CURRENT_DATE + itemsite_eventfence))
     AND (evnttype_name=''WoCreated'') );

     IF (_cmnttypeid <> -1) THEN
       PERFORM postComment(_cmnttypeid, ''W'', NEW.wo_id, ''Created'');
     END IF;

     RETURN NEW;

  ELSE
    IF (TG_OP = ''DELETE'') THEN
      INSERT INTO evntlog ( evntlog_evnttime, evntlog_username, evntlog_evnttype_id,
                            evntlog_ordtype, evntlog_ord_id, evntlog_warehous_id, evntlog_number )
      SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,
             ''W'', OLD.wo_id, itemsite_warehous_id, (OLD.wo_number || ''-'' || OLD.wo_subnumber) 
      FROM evntnot, evnttype, itemsite, item
      WHERE ( (evntnot_evnttype_id=evnttype_id)
       AND (evntnot_warehous_id=itemsite_warehous_id)
       AND (itemsite_id=OLD.wo_itemsite_id)
       AND (itemsite_item_id=item_id)
       AND (OLD.wo_duedate <= (CURRENT_DATE + itemsite_eventfence))
       AND (evnttype_name=''WoCancelled'') );

      DELETE FROM comment
      WHERE ( (comment_source=''W'')
       AND (comment_source_id=OLD.wo_id) );

      DELETE FROM charass
       WHERE ((charass_target_type=''W'')
         AND  (charass_target_id=OLD.wo_id));

       RETURN OLD;

    ELSE
      IF (TG_OP = ''UPDATE'') THEN

        IF (NEW.wo_qtyord <> OLD.wo_qtyord) THEN
          INSERT INTO evntlog ( evntlog_evnttime, evntlog_username, evntlog_evnttype_id,
                                evntlog_ordtype, evntlog_ord_id, evntlog_warehous_id, evntlog_number,
                                evntlog_oldvalue, evntlog_newvalue )
          SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,
                 ''W'', NEW.wo_id, itemsite_warehous_id, (NEW.wo_number || ''-'' || NEW.wo_subnumber),
                 OLD.wo_qtyord, NEW.wo_qtyord
          FROM evntnot, evnttype, itemsite, item
          WHERE ( (evntnot_evnttype_id=evnttype_id)
           AND (evntnot_warehous_id=itemsite_warehous_id)
           AND (itemsite_id=NEW.wo_itemsite_id)
           AND (itemsite_item_id=item_id)
           AND ( (NEW.wo_duedate <= (CURRENT_DATE + itemsite_eventfence))
            OR   (OLD.wo_duedate <= (CURRENT_DATE + itemsite_eventfence)) )
           AND (evnttype_name=''WoQtyChanged'') );

          IF (_cmnttypeid <> -1) THEN
            PERFORM postComment( _cmnttypeid, ''W'', NEW.wo_id,
                                 ( ''Qty. Ordered Changed from '' || formatQty(OLD.wo_qtyord) ||
                                   '' to '' || formatQty(NEW.wo_qtyord ) ) );
          END IF;
        END IF;

        IF (NEW.wo_duedate <> OLD.wo_duedate) THEN
          INSERT INTO evntlog ( evntlog_evnttime, evntlog_username, evntlog_evnttype_id,
                                evntlog_ordtype, evntlog_ord_id, evntlog_warehous_id, evntlog_number,
                                evntlog_olddate, evntlog_newdate )
          SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,
                 ''W'', NEW.wo_id, itemsite_warehous_id, (NEW.wo_number || ''-'' || NEW.wo_subnumber),
                 OLD.wo_duedate, NEW.wo_duedate
          FROM evntnot, evnttype, itemsite, item
          WHERE ( (evntnot_evnttype_id=evnttype_id)
           AND (evntnot_warehous_id=itemsite_warehous_id)
           AND (itemsite_id=NEW.wo_itemsite_id)
           AND (itemsite_item_id=item_id)
           AND ( (NEW.wo_duedate <= (CURRENT_DATE + itemsite_eventfence))
            OR   (OLD.wo_duedate <= (CURRENT_DATE + itemsite_eventfence)) )
           AND (evnttype_name=''WoDueDateChanged'') );

          IF (_cmnttypeid <> -1) THEN
            PERFORM postComment( _cmnttypeid, ''W'', NEW.wo_id,
                                 ( ''Due Date Changed from '' || formatDate(OLD.wo_duedate) ||
                                   '' to '' || formatDate(NEW.wo_duedate ) ) );
          END IF;
        END IF;

        IF (NEW.wo_status <> OLD.wo_status) THEN
          IF (_cmnttypeid <> -1) THEN
            PERFORM postComment( _cmnttypeid, ''W'', NEW.wo_id,
                                 (''Status Changed from '' || OLD.wo_status || '' to '' || NEW.wo_status) );
          END IF;
        END IF;

      END IF; 
    END IF;
  END IF;

  RETURN NEW;

END;
' LANGUAGE 'plpgsql';

DROP TRIGGER woTrigger ON wo;
CREATE TRIGGER woTrigger BEFORE INSERT OR UPDATE OR DELETE ON wo FOR EACH ROW EXECUTE PROCEDURE _woTrigger();
