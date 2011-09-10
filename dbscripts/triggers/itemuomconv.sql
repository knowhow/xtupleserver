CREATE OR REPLACE FUNCTION _itemuomconvTrigger () RETURNS TRIGGER AS '
BEGIN

-- Privilege Checks
   IF (NOT checkPrivilege(''MaintainItemMasters'')) THEN
     RAISE EXCEPTION ''You do not have privileges to maintain Items.'';
   END IF;
  
  RETURN NEW;
END;
' LANGUAGE 'plpgsql';

DROP TRIGGER itemuomconvTrigger ON itemuomconv;
CREATE TRIGGER itemuomconvTrigger AFTER INSERT OR UPDATE ON itemuomconv FOR EACH ROW EXECUTE PROCEDURE _itemuomconvTrigger();
