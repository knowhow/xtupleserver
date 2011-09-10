CREATE OR REPLACE FUNCTION changePrQty(INTEGER, DATE) RETURNS INTEGER AS '
DECLARE
  pPrid ALIAS FOR $1;
  pDueDate ALIAS FOR $2;

BEGIN

  UPDATE pr
  SET pr_duedate=pDueDate
  WHERE (pr_id=pPrid);

  RETURN 0;

END;
' LANGUAGE 'plpgsql';
