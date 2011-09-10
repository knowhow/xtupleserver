CREATE OR REPLACE FUNCTION createAPCreditMemoApplication(INTEGER, INTEGER, NUMERIC, INTEGER) RETURNS INTEGER AS '
DECLARE
  pSourceApopenId	ALIAS FOR $1;
  pTargetApopenId	ALIAS FOR $2;
  pAmount		ALIAS FOR $3;
  pCurrId		ALIAS FOR $4;
  _apCreditApplyId	INTEGER;

BEGIN
  IF (pAmount > (SELECT ROUND(apopen_amount - apopen_paid, 2)
		  FROM apopen
		 WHERE (apopen_id=pTargetApopenId))) THEN
    RETURN -1;
  END IF;

  IF (pAmount > (SELECT ROUND((apopen_amount - apopen_paid) - 
		       COALESCE(SUM(currToCurr(apcreditapply_curr_id,
						apopen_curr_id, 
						apcreditapply_amount, 
						apopen_docdate)), 0), 2)
             FROM apopen LEFT OUTER JOIN apcreditapply 
               ON ((apcreditapply_source_apopen_id=apopen_id) 
              AND (apcreditapply_target_apopen_id<>pTargetApopenId)) 
             WHERE (apopen_id=pSourceApopenId) 
             GROUP BY apopen_amount, apopen_paid)) THEN
      RETURN -2;
    END IF;

  SELECT apcreditapply_id INTO _apCreditApplyId
    FROM apcreditapply
   WHERE ((apcreditapply_source_apopen_id=pSourceApopenId)
     AND  (apcreditapply_target_apopen_id=pTargetApopenId));

  IF (FOUND) THEN
    UPDATE apcreditapply SET apcreditapply_amount=pAmount,
			     apcreditapply_curr_id=pCurrId
    WHERE (apcreditapply_id=_apCreditApplyId);
  ELSE
    _apCreditApplyId := NEXTVAL(''apcreditapply_apcreditapply_id_seq'');
    INSERT INTO apcreditapply (
      apcreditapply_id, apcreditapply_source_apopen_id,
      apcreditapply_target_apopen_id,
      apcreditapply_amount, apcreditapply_curr_id
    ) VALUES (
      _apCreditApplyId, pSourceApopenId,
      pTargetApopenId,
      pAmount, pCurrId);
  END IF;

  RETURN _apCreditApplyId;

END;
' LANGUAGE 'plpgsql';
