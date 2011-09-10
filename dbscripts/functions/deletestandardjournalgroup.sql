
CREATE OR REPLACE FUNCTION deleteStandardJournalGroup(INTEGER) RETURNS INTEGER AS '
DECLARE
  pStdjrnlgrpid ALIAS FOR $1;

BEGIN

  DELETE FROM stdjrnlgrpitem
  WHERE (stdjrnlgrpitem_stdjrnlgrp_id=pStdjrnlgrpid);

  DELETE FROM stdjrnlgrp
  WHERE (stdjrnlgrp_id=pStdjrnlgrpid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';

