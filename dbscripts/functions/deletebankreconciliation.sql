
CREATE OR REPLACE FUNCTION deleteBankReconciliation(INTEGER) RETURNS INTEGER AS '
DECLARE
  pbankrecid    ALIAS FOR $1;
BEGIN
  DELETE FROM bankrecitem
  WHERE bankrecitem_bankrec_id=pbankrecid;

  DELETE FROM bankrec
  WHERE bankrec_id=pbankrecid;

  RETURN 0;
END;
' LANGUAGE 'plpgsql';

