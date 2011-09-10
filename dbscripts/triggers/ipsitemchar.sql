CREATE OR REPLACE FUNCTION _ipsitemcharBeforeTrigger () RETURNS TRIGGER AS '
BEGIN

  --  Checks
  IF NOT (checkPrivilege(''MaintainPricingSchedules'')) THEN
    RAISE EXCEPTION ''You do not have privileges to maintain Price Schedules.'';
  END IF;
  
  IF (TG_OP IN (''INSERT'',''UPDATE'')) THEN
    IF (SELECT (COUNT(item_id)=0)
        FROM item,ipsitem 
        WHERE ((ipsitem_id=NEW.ipsitemchar_ipsitem_id)
        AND (item_id=ipsitem_item_id)
        AND (item_config))) THEN
      RAISE EXCEPTION ''Characteristic prices may only be set on configured items.'';
    ELSIF (SELECT (COUNT(item_id)=0)
        FROM item,ipsitem,charass,char 
        WHERE ((ipsitem_id=NEW.ipsitemchar_ipsitem_id)
        AND (item_id=ipsitem_item_id)
        AND (item_id=charass_target_id)
        AND (''I''=charass_target_type)
        AND (charass_char_id=NEW.ipsitemchar_char_id)
        AND (charass_value=NEW.ipsitemchar_value))) THEN
      RAISE EXCEPTION ''No characteristic with matching value exists for this item.'';
    END IF;
    RETURN NEW;
  ELSE
    RETURN OLD;
  END IF;
END;
' LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'ipsitemcharBeforeTrigger');
CREATE TRIGGER ipsitemcharBeforeTrigger BEFORE INSERT OR UPDATE OR DELETE ON ipsitemchar FOR EACH ROW EXECUTE PROCEDURE _ipsitemcharBeforeTrigger();
