CREATE OR REPLACE FUNCTION updateSorACost(INTEGER, TEXT, BOOLEAN, NUMERIC, BOOLEAN) RETURNS INTEGER AS '
DECLARE
  pItemid	ALIAS FOR $1;
  pCosttype	ALIAS FOR $2;
  pLevel	ALIAS FOR $3;
  pCost		ALIAS FOR $4;
  pUpdateActual	ALIAS FOR $5;

BEGIN
    IF (pUpdateActual) THEN
	RETURN updateCost(pItemid, pCosttype, pLevel, pCost);
    ELSE
	RETURN updateStdCost(pItemid, pCosttype, pLevel, pCost);
    END IF;
END;
' LANGUAGE 'plpgsql';

