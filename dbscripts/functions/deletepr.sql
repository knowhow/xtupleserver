CREATE OR REPLACE FUNCTION deletePr(CHAR, INTEGER) RETURNS BOOL AS '
DECLARE
  pParentType ALIAS FOR $1;
  pParentId ALIAS FOR $2;

BEGIN

  DELETE FROM pr
  WHERE ((pr_status=''O'')
   AND (pr_order_type=pParentType)
   AND (pr_order_id=pParentId));

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION deletePr(INTEGER) RETURNS BOOL AS '
DECLARE
  pPrid ALIAS FOR $1;

BEGIN

  DELETE FROM pr
  WHERE ( (pr_status=''O'')
   AND (pr_id=pPrid) );

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
