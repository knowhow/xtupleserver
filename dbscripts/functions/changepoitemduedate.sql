CREATE OR REPLACE FUNCTION changePoitemDueDate(INTEGER, DATE) RETURNS INTEGER AS '
DECLARE
  pPoitemid ALIAS FOR $1;
  pDate ALIAS FOR $2;

BEGIN

  IF ( ( SELECT (poitem_status IN (''C''))
         FROM poitem
         WHERE (poitem_id=pPoitemid) ) ) THEN
    RETURN -1;
  END IF;

  UPDATE poitem
  SET poitem_duedate=pDate
  WHERE (poitem_id=pPoitemid);

  RETURN pPoitemid;

END;
' LANGUAGE 'plpgsql';
