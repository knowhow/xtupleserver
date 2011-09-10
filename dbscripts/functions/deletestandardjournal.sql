
CREATE OR REPLACE FUNCTION deleteStandardJournal(INTEGER) RETURNS INTEGER AS '
DECLARE
  pStdjrnlid ALIAS FOR $1;

BEGIN

  DELETE FROM stdjrnlitem
  WHERE (stdjrnlitem_stdjrnl_id=pStdjrnlid);

  DELETE FROM stdjrnlgrpitem
  WHERE (stdjrnlgrpitem_stdjrnl_id=pStdjrnlid);

  DELETE FROM stdjrnl
  WHERE (stdjrnl_id=pStdjrnlid);

  RETURN 1;

END;
' LANGUAGE 'plpgsql';

