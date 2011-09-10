CREATE OR REPLACE FUNCTION deleteFlgrp(INTEGER) RETURNS INTEGER AS '
DECLARE
  pFlgrpid ALIAS FOR $1;
  _r RECORD;

BEGIN

  FOR _r IN SELECT flgrp_id
            FROM flgrp
            WHERE (flgrp_flgrp_id=pFlgrpid) LOOP
    PERFORM deleteFlgrp(_r.flgrp_id);
  END LOOP;

  DELETE FROM flitem
  WHERE (flitem_flgrp_id=pFlgrpid);

  DELETE FROM flspec
  WHERE (flspec_flgrp_id=pFlgrpid);

  DELETE FROM flgrp
  WHERE (flgrp_id=pFlgrpid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';