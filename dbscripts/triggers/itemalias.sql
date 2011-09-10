CREATE OR REPLACE FUNCTION _itemaliasTrigger () RETURNS TRIGGER AS '
BEGIN

-- Privilege Checks
   IF (NOT checkPrivilege(''MaintainItemMasters'') OR NOT checkPrivilege(''MaintainItemAliases'')) THEN
     RAISE EXCEPTION ''You do not have privileges to maintain Item Aliases.'';
   END IF;
  
  RETURN NEW;
END;
' LANGUAGE 'plpgsql';

DROP TRIGGER itemaliasTrigger ON itemalias;
CREATE TRIGGER itemaliasTrigger AFTER INSERT OR UPDATE ON itemalias FOR EACH ROW EXECUTE PROCEDURE _itemaliasTrigger();
