CREATE OR REPLACE FUNCTION _prjTrigger () RETURNS TRIGGER AS $$
DECLARE
  _test text;
BEGIN

  --  Checks
  IF (NEW.prj_owner_username=getEffectiveXtUser()) THEN
    IF (NOT checkPrivilege('MaintainAllProjects') AND NOT checkPrivilege('MaintainPersonalProjects')) THEN
      RAISE EXCEPTION 'You do not have privileges to maintain Projects.';
    END IF;
  ELSIF (NOT checkPrivilege('MaintainAllProjects')) THEN
    RAISE EXCEPTION 'You do not have privileges to maintain Projects.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'prjTrigger');
CREATE TRIGGER prjTrigger BEFORE INSERT OR UPDATE ON prj FOR EACH ROW EXECUTE PROCEDURE _prjTrigger();

CREATE OR REPLACE FUNCTION _prjBeforeDeleteTrigger() RETURNS TRIGGER AS $$
DECLARE
  _recurid     INTEGER;
  _newparentid INTEGER;
BEGIN
  IF (OLD.prj_owner_username=getEffectiveXtUser()) THEN
    IF (NOT checkPrivilege('MaintainAllProjects') AND NOT checkPrivilege('MaintainPersonalProjects')) THEN
      RAISE EXCEPTION 'You do not have privileges to maintain Projects.';
    END IF;
  ELSIF (NOT checkPrivilege('MaintainAllProjects')) THEN
    RAISE EXCEPTION 'You do not have privileges to maintain Projects.';
  END IF;

  IF (TG_OP = 'DELETE') THEN
    SELECT recur_id INTO _recurid
      FROM recur
     WHERE ((recur_parent_id=OLD.prj_id)
        AND (recur_parent_type='J'));

    IF (_recurid IS NOT NULL) THEN
      SELECT MIN(prj_id) INTO _newparentid
        FROM prj
       WHERE ((prj_recurring_prj_id=OLD.prj_id)
          AND (prj_id!=OLD.prj_id));

      -- client is responsible for warning about deleting a recurring prj
      IF (_newparentid IS NULL) THEN
        DELETE FROM recur WHERE recur_id=_recurid;
      ELSE
        UPDATE recur SET recur_parent_id=_newparentid
         WHERE recur_id=_recurid;
      END IF;

    END IF;

    RETURN OLD;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'prjbeforedeletetrigger');
CREATE TRIGGER prjbeforedeletetrigger
  BEFORE DELETE
  ON prj
  FOR EACH ROW
  EXECUTE PROCEDURE _prjBeforeDeleteTrigger();
