
CREATE OR REPLACE FUNCTION deleteBudget(INTEGER) RETURNS INTEGER AS '
DECLARE
  pBudgheadid ALIAS FOR $1;

BEGIN
  DELETE FROM budgitem WHERE (budgitem_budghead_id=pBudgheadid);
  DELETE FROM budghead WHERE (budghead_id=pBudgheadid);

  RETURN pBudgheadid;
END;
' LANGUAGE 'plpgsql';

