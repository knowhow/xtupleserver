
CREATE OR REPLACE FUNCTION createARCashDeposit(INTEGER, TEXT, TEXT, DATE, NUMERIC, TEXT, INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pCustid ALIAS FOR $1;
  pDocNumber ALIAS FOR $2;
  pOrderNumber ALIAS FOR $3;
  pDocDate ALIAS FOR $4;
  pAmount ALIAS FOR $5;
  pNotes ALIAS FOR $6;
  pJournalNumber ALIAS FOR $7;
  pCurrId ALIAS FOR $8;
  _glSequence INTEGER;
  _aropenid INTEGER;

BEGIN

  IF (pAmount <= 0) THEN
    RETURN 0;
  END IF;

  SELECT NEXTVAL('aropen_aropen_id_seq') INTO _aropenid;

  SELECT insertGLTransaction( pJournalNumber, 'A/R', 'CD',
                              pDocNumber, pNotes, cr.accnt_id, db.accnt_id,
                              _aropenid,
                              round(currToBase(pCurrId, pAmount, pDocDate), 2),
                              pDocDate) INTO _glSequence
  FROM accnt AS db, accnt AS cr
  WHERE ( (db.accnt_id = findPrepaidAccount(pCustid))
   AND (cr.accnt_id = findDeferredAccount(pCustid)) );
  IF (NOT FOUND) THEN
    RAISE EXCEPTION 'There was an error creating the Customer Deposit GL Transactions. No Deferred Revenue Account is assigned.';
  END IF;

  INSERT INTO aropen
  ( aropen_id, aropen_username, aropen_journalnumber,
    aropen_cust_id, aropen_docnumber, aropen_doctype, aropen_ordernumber,
    aropen_docdate, aropen_duedate, aropen_distdate, aropen_terms_id, aropen_salesrep_id,
    aropen_amount, aropen_paid, aropen_commission_due, aropen_commission_paid,
    aropen_applyto, aropen_ponumber, aropen_cobmisc_id,
    aropen_open, aropen_notes, aropen_rsncode_id,
    aropen_salescat_id, aropen_accnt_id, aropen_curr_id )
  VALUES
  ( _aropenid, getEffectiveXtUser(), pJournalNumber,
    pCustid, pDocNumber, 'R', pOrderNumber,
    pDocDate, pDocDate, pDocDate, -1, NULL,
    round(pAmount, 2), 0, 0.0, FALSE,
    '', '', -1,
    TRUE, pNotes, -1,
    -1, -1, pCurrId );

  RETURN _aropenid;

END;
$$ LANGUAGE 'plpgsql';

