CREATE OR REPLACE FUNCTION _itemtaxTrigger () RETURNS TRIGGER AS '
BEGIN

-- Privilege Checks
   IF (NOT checkPrivilege(''MaintainItemMasters'')) THEN
     RAISE EXCEPTION ''You do not have privileges to maintain Items.'';
   END IF;
  
  RETURN NEW;
END;
' LANGUAGE 'plpgsql';

DROP TRIGGER itemtaxTrigger ON itemtax;
CREATE TRIGGER itemtaxTrigger AFTER INSERT OR UPDATE ON itemtax FOR EACH ROW EXECUTE PROCEDURE _itemtaxTrigger();
