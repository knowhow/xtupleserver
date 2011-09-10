CREATE OR REPLACE FUNCTION _bomheadTrigger() RETURNS TRIGGER AS '
DECLARE
  _revid INTEGER;
  _check TEXT;
BEGIN
-- Privilege Checks
  IF (NOT checkPrivilege(''MaintainBOMs'')) THEN
    RAISE EXCEPTION ''You do not have privileges to maintain Bills of Material.'';
  END IF;
  
  RETURN NEW;
END;
' LANGUAGE 'plpgsql';

DROP TRIGGER bomheadTrigger ON bomhead;
CREATE TRIGGER bomheadTrigger AFTER INSERT OR UPDATE OR DELETE ON bomhead FOR EACH ROW EXECUTE PROCEDURE _bomheadTrigger();
