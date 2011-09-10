CREATE OR REPLACE FUNCTION _itemsubTrigger () RETURNS TRIGGER AS '
BEGIN

-- Privilege Checks
   IF (NOT checkPrivilege(''MaintainItemMasters'') OR NOT checkPrivilege(''MaintainItemSubstitutes'')) THEN
     RAISE EXCEPTION ''You do not have privileges to maintain Item Substitutes.'';
   END IF;
  
  RETURN NEW;
END;
' LANGUAGE 'plpgsql';

DROP TRIGGER itemsubTrigger ON itemsub;
CREATE TRIGGER itemsubTrigger AFTER INSERT OR UPDATE ON itemsub FOR EACH ROW EXECUTE PROCEDURE _itemsubTrigger();
