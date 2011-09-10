
CREATE OR REPLACE FUNCTION deleteBudgetItems(INTEGER) RETURNS INTEGER AS '
DECLARE
  pBudgheadid ALIAS FOR $1;

BEGIN
  DELETE FROM budgitem WHERE (budgitem_budghead_id=pBudgheadid);

  RETURN pBudgheadid;
END;
' LANGUAGE 'plpgsql';

