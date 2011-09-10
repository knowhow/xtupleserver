CREATE OR REPLACE FUNCTION _itemCostTrigger() RETURNS TRIGGER AS $$
BEGIN

  --Privilege Checks
  IF ( (TG_OP = 'INSERT') AND (NOT checkPrivilege('CreateCosts')) AND (NOT checkPrivilege('PostVouchers')) ) THEN
    RAISE EXCEPTION 'You do not have privileges to enter Item Costs.';
  END IF;

  IF ( (TG_OP = 'UPDATE') AND (NOT checkPrivilege('EnterActualCosts')) AND (NOT checkPrivilege('PostVouchers')) AND (NOT checkPrivilege('UpdateActualCosts')) AND (NOT checkPrivilege('PostActualCosts')) AND (NOT checkPrivilege('PostStandardCosts')) ) THEN
    RAISE EXCEPTION 'You do not have privileges to update Item Costs.';
  END IF;

  IF ( (TG_OP = 'DELETE') AND (NOT checkPrivilege('DeleteCosts')) ) THEN
    RAISE EXCEPTION 'You do not have privileges to delete Item Costs.';
  END IF;

  IF (TG_OP = 'UPDATE') THEN
    IF (NEW.itemcost_actcost <> OLD.itemcost_actcost OR
        NEW.itemcost_curr_id <> OLD.itemcost_curr_id) THEN
      INSERT INTO costhist
      ( costhist_item_id, costhist_costelem_id, costhist_type,
        costhist_lowlevel, costhist_username, costhist_date,
        costhist_oldcost, costhist_newcost,
        costhist_oldcurr_id, costhist_newcurr_id )
      VALUES
      ( NEW.itemcost_item_id, NEW.itemcost_costelem_id, 'A',
        NEW.itemcost_lowlevel, getEffectiveXtUser(), CURRENT_TIMESTAMP,
        OLD.itemcost_actcost, NEW.itemcost_actcost,
        OLD.itemcost_curr_id, NEW.itemcost_curr_id );
    END IF;

    IF (NEW.itemcost_stdcost <> OLD.itemcost_stdcost) THEN
      INSERT INTO costhist
      ( costhist_item_id, costhist_costelem_id, costhist_type,
        costhist_lowlevel, costhist_username, costhist_date,
        costhist_oldcost, costhist_newcost,
        costhist_oldcurr_id, costhist_newcurr_id )
      VALUES
      ( NEW.itemcost_item_id, NEW.itemcost_costelem_id, 'S',
        NEW.itemcost_lowlevel, getEffectiveXtUser(), CURRENT_TIMESTAMP,
        OLD.itemcost_stdcost, NEW.itemcost_stdcost,
        baseCurrId(), baseCurrId() );
    END IF;

    RETURN NEW;

  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO costhist
    ( costhist_item_id, costhist_costelem_id, costhist_type,
      costhist_lowlevel, costhist_username, costhist_date,
      costhist_oldcost, costhist_newcost,
      costhist_oldcurr_id, costhist_newcurr_id )
    VALUES
    ( NEW.itemcost_item_id, NEW.itemcost_costelem_id, 'N',
      NEW.itemcost_lowlevel, getEffectiveXtUser(), CURRENT_TIMESTAMP,
      0, NEW.itemcost_actcost,
      baseCurrId(), NEW.itemcost_curr_id );

    RETURN NEW;

  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO costhist
    ( costhist_item_id, costhist_costelem_id, costhist_type,
      costhist_lowlevel, costhist_username, costhist_date,
      costhist_oldcost, costhist_newcost,
      costhist_oldcurr_id, costhist_newcurr_id )
    VALUES
    ( OLD.itemcost_item_id, OLD.itemcost_costelem_id, 'D',
      OLD.itemcost_lowlevel, getEffectiveXtUser(), CURRENT_TIMESTAMP,
      OLD.itemcost_stdcost, 0,
      OLD.itemcost_curr_id, baseCurrId() );

    RETURN OLD;
  END IF;

END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER itemCostTrigger ON itemcost;
CREATE TRIGGER itemCostTrigger BEFORE INSERT OR UPDATE OR DELETE ON itemcost FOR EACH ROW EXECUTE PROCEDURE _itemCostTrigger();



CREATE OR REPLACE FUNCTION _itemCostAfterTrigger() RETURNS TRIGGER AS $$
DECLARE
  _itemNumber TEXT;
  _maxCost NUMERIC;
  _oldStdCost NUMERIC;
  _oldActCost NUMERIC;
  _costElem TEXT;
BEGIN

--  Create Event if Standard or Actual Cost is greater than Max Cost

  SELECT item_number, item_maxcost INTO _itemNumber, _maxCost
  FROM item
  WHERE (item_id=NEW.itemcost_item_id);

  SELECT costelem_type INTO _costElem
  FROM costelem
  WHERE (costelem_id=NEW.itemcost_costelem_id);

  IF (_maxCost > 0.0) THEN
    IF (stdCost(NEW.itemcost_item_id) > _maxCost) 
      AND
      ( 
               (SELECT COUNT(evntlog_id) FROM
                      evntlog, evnttype
                      WHERE evntlog_evnttype_id = evnttype_id 
                      AND evntlog_number LIKE 
                           (_itemNumber || '%' || 
                           'New: ' || formatCost(stdCost(NEW.itemcost_item_id)) || 
                           ' Max: ' || formatCost(_maxCost))
                      AND CAST(evntlog_evnttime AS DATE) = current_date
                      ) = 0)
       THEN
      IF (TG_OP = 'INSERT') THEN
        _oldStdCost := 0;
        _oldActCost := 0;
      ELSE
        _oldStdCost := OLD.itemcost_stdcost;
        _oldActCost := OLD.itemcost_stdcost;
      END IF; 
      INSERT INTO evntlog ( evntlog_evnttime, evntlog_username, evntlog_evnttype_id,
                            evntlog_ordtype, evntlog_ord_id, evntlog_warehous_id, evntlog_number,
                            evntlog_newvalue, evntlog_oldvalue )
      SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,
             '', NEW.itemcost_item_id, itemsite_warehous_id,
               (_itemNumber || ' -Standard- ' || 
               'New: ' || formatCost(stdCost(NEW.itemcost_item_id)) ||
               ' Max: '|| formatCost(_MaxCost)),
               NEW.itemcost_stdcost, _oldStdCost
      FROM evntnot, evnttype, itemsite
      WHERE ( (evntnot_evnttype_id=evnttype_id)
        AND   (itemsite_item_id=NEW.itemcost_item_id)
        AND   (evntnot_warehous_id=itemsite_warehous_id)
        AND   (evnttype_name='CostExceedsMaxDesired') );
    END IF;
    IF (actCost(NEW.itemcost_item_id) > _maxCost) 
     AND   ( 
                (SELECT COUNT(evntlog_id) FROM
                      evntlog, evnttype
                      WHERE evntlog_evnttype_id = evnttype_id 
                      AND evntlog_number LIKE 
                           (_itemNumber || '%' || 
                           'New: ' || formatCost(actCost(NEW.itemcost_item_id)) || 
                           ' Max: ' || formatCost(_maxCost))
                      AND CAST(evntlog_evnttime AS DATE) = current_date
                      ) = 0
              )
      THEN
      INSERT INTO evntlog ( evntlog_evnttime, evntlog_username, evntlog_evnttype_id,
                            evntlog_ordtype, evntlog_ord_id, evntlog_warehous_id, evntlog_number,
                            evntlog_newvalue, evntlog_oldvalue )
      SELECT CURRENT_TIMESTAMP, evntnot_username, evnttype_id,
             '', NEW.itemcost_item_id, itemsite_warehous_id,
               (_itemNumber || ' -Actual- ' || 
               'New: ' || formatCost(actCost(NEW.itemcost_item_id)) ||
               ' Max: '|| formatCost(_MaxCost)),
             NEW.itemcost_actcost, _oldActCost
      FROM evntnot, evnttype, itemsite
      WHERE ( (evntnot_evnttype_id=evnttype_id)
        AND   (itemsite_item_id=NEW.itemcost_item_id)
        AND   (evntnot_warehous_id=itemsite_warehous_id)
        AND   (evnttype_name='CostExceedsMaxDesired') );
    END IF;
  END IF;

  RETURN NEW;

END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER itemCostAfterTrigger ON itemcost;
CREATE TRIGGER itemCostAfterTrigger AFTER INSERT OR UPDATE ON itemcost FOR EACH ROW EXECUTE PROCEDURE _itemCostAfterTrigger();
