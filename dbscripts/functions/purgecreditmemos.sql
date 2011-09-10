CREATE OR REPLACE FUNCTION purgeCreditMemos(DATE) RETURNS BOOLEAN AS '
DECLARE
  pCutoffDate ALIAS FOR $1;

BEGIN

  DELETE FROM cmitem
  WHERE (cmitem_id IN ( SELECT cmitem_id
                        FROM cmitem, cmhead
                        WHERE ( (cmitem_cmhead_id=cmhead_id)
                          AND   (cmhead_posted)
                          AND   (cmhead_printed)
                          AND   (cmhead_docdate<=pCutoffDate)
                          AND   (checkCreditMemoSitePrivs(cmhead_id)) ) ) );

  DELETE FROM cmhead
  WHERE ( (cmhead_posted)
    AND   (cmhead_printed)
    AND   (cmhead_docdate<=pCutoffDate)
    AND   (checkCreditMemoSitePrivs(cmhead_id)) );

  RETURN TRUE;

END;
' LANGUAGE 'plpgsql';
