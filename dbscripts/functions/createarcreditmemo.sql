
CREATE OR REPLACE FUNCTION createARCreditMemo(INTEGER, TEXT, TEXT, DATE, NUMERIC, TEXT) RETURNS INTEGER AS $$
DECLARE
  pCustid ALIAS FOR $1;
  pDocNumber ALIAS FOR $2;
  pOrderNumber ALIAS FOR $3;
  pDocDate ALIAS FOR $4;
  pAmount ALIAS FOR $5;
  pNotes ALIAS FOR $6;
BEGIN
  RETURN createARCreditMemo(pCustid, pDocNumber, pOrderNumber, pDocDate, pAmount, pNotes, -1, -1, -1, pDocDate, -1, NULL, 0, NULL, baseCurrId() );
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION createARCreditMemo(INTEGER, TEXT, TEXT, DATE, NUMERIC, TEXT, INTEGER)
RETURNS INTEGER AS $$
DECLARE
  pCustid ALIAS FOR $1;
  pDocNumber ALIAS FOR $2;
  pOrderNumber ALIAS FOR $3;
  pDocDate ALIAS FOR $4;
  pAmount ALIAS FOR $5;
  pNotes ALIAS FOR $6;
  pCurrId ALIAS FOR $7;
BEGIN
  RETURN createARCreditMemo(pCustid, pDocNumber, pOrderNumber, pDocDate, pAmount, pNotes, -1, -1, -1, pDocDate, -1, NULL, 0, NULL, pCurrId);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION createARCreditMemo(INTEGER, TEXT, TEXT, DATE, NUMERIC, TEXT, INTEGER, INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pCustid ALIAS FOR $1;
  pDocNumber ALIAS FOR $2;
  pOrderNumber ALIAS FOR $3;
  pDocDate ALIAS FOR $4;
  pAmount ALIAS FOR $5;
  pNotes ALIAS FOR $6;
  pRsncodeid ALIAS FOR $7;
  pSalescatid ALIAS FOR $8;
  pAccntid ALIAS FOR $9;
BEGIN
  RETURN createARCreditMemo(pCustid, pDocNumber, pOrderNumber, pDocDate, pAmount, pNotes, pRsncodeid, pSalescatid, pAccntid, pDocDate, -1, NULL, 0, NULL, baseCurrId() );
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION createARCreditMemo(INTEGER, TEXT, TEXT, DATE, NUMERIC, TEXT, INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER, NUMERIC) RETURNS INTEGER AS $$
DECLARE
  pCustid ALIAS FOR $1;
  pDocNumber ALIAS FOR $2;
  pOrderNumber ALIAS FOR $3;
  pDocDate ALIAS FOR $4;
  pAmount ALIAS FOR $5;
  pNotes ALIAS FOR $6;
  pRsncodeid ALIAS FOR $7;
  pSalescatid ALIAS FOR $8;
  pAccntid ALIAS FOR $9;
  pDueDate ALIAS FOR $10;
  pTermsid ALIAS FOR $11;
  pSalesrepid ALIAS FOR $12;
  pCommissiondue ALIAS FOR $13;

BEGIN
  RETURN createARCreditMemo(pCustid, pDocNumber, pOrderNumber, pDocDate, pAmount, pNotes, pRsncodeid, pSalescatid, pAccntid, pDueDate, pTermsid, pSalesrepid, pCommissiondue, NULL, baseCurrId() );
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION createARCreditMemo(INTEGER, TEXT, TEXT, DATE, NUMERIC, TEXT, INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER, NUMERIC, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pCustid ALIAS FOR $1;
  pDocNumber ALIAS FOR $2;
  pOrderNumber ALIAS FOR $3;
  pDocDate ALIAS FOR $4;
  pAmount ALIAS FOR $5;
  pNotes ALIAS FOR $6;
  pRsncodeid ALIAS FOR $7;
  pSalescatid ALIAS FOR $8;
  pAccntid ALIAS FOR $9;
  pDueDate ALIAS FOR $10;
  pTermsid ALIAS FOR $11;
  pSalesrepid ALIAS FOR $12;
  pCommissiondue ALIAS FOR $13;
  pCurrId ALIAS FOR $14;

BEGIN
  RETURN createARCreditMemo(pCustid, pDocNumber, pOrderNumber, pDocDate, pAmount, pNotes, pRsncodeid, pSalescatid, pAccntid, pDueDate, pTermsid, pSalesrepid, pCommissiondue, NULL, pCurrId );
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION createARCreditMemo(INTEGER, INTEGER, TEXT, TEXT, DATE, NUMERIC, TEXT, INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER, NUMERIC, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pId ALIAS FOR $1;
  pCustid ALIAS FOR $2;
  pDocNumber ALIAS FOR $3;
  pOrderNumber ALIAS FOR $4;
  pDocDate ALIAS FOR $5;
  pAmount ALIAS FOR $6;
  pNotes ALIAS FOR $7;
  pRsncodeid ALIAS FOR $8;
  pSalescatid ALIAS FOR $9;
  pAccntid ALIAS FOR $10;
  pDueDate ALIAS FOR $11;
  pTermsid ALIAS FOR $12;
  pSalesrepid ALIAS FOR $13;
  pCommissiondue ALIAS FOR $14;
  pCurrId ALIAS FOR $15;

BEGIN
  RETURN createARCreditMemo(pId, pCustid, pDocNumber, pOrderNumber, pDocDate, pAmount, pNotes, pRsncodeid, pSalescatid, pAccntid, pDueDate, pTermsid, pSalesrepid, pCommissiondue, NULL, pCurrId, NULL );
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION createARCreditMemo(INTEGER, TEXT, TEXT, DATE, NUMERIC, TEXT, INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER, NUMERIC, INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pCustid ALIAS FOR $1;
  pDocNumber ALIAS FOR $2;
  pOrderNumber ALIAS FOR $3;
  pDocDate ALIAS FOR $4;
  pAmount ALIAS FOR $5;
  pNotes ALIAS FOR $6;
  pRsncodeid ALIAS FOR $7;
  pSalescatid ALIAS FOR $8;
  pAccntid ALIAS FOR $9;
  pDueDate ALIAS FOR $10;
  pTermsid ALIAS FOR $11;
  pSalesrepid ALIAS FOR $12;
  pCommissiondue ALIAS FOR $13;
  pJournalNumber ALIAS FOR $14;
  pCurrId ALIAS FOR $15;

BEGIN
  RETURN createARCreditMemo(NULL, pCustid, pDocNumber, pOrderNumber, pDocDate, pAmount, pNotes, pRsncodeid, pSalescatid, pAccntid, pDueDate, pTermsid, pSalesrepid, pCommissiondue, pJournalNumber, pCurrId, NULL );
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION createARCreditMemo(INTEGER, TEXT, TEXT, DATE, NUMERIC, TEXT, INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER, NUMERIC, INTEGER, INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pCustid ALIAS FOR $1;
  pDocNumber ALIAS FOR $2;
  pOrderNumber ALIAS FOR $3;
  pDocDate ALIAS FOR $4;
  pAmount ALIAS FOR $5;
  pNotes ALIAS FOR $6;
  pRsncodeid ALIAS FOR $7;
  pSalescatid ALIAS FOR $8;
  pAccntid ALIAS FOR $9;
  pDueDate ALIAS FOR $10;
  pTermsid ALIAS FOR $11;
  pSalesrepid ALIAS FOR $12;
  pCommissiondue ALIAS FOR $13;
  pJournalNumber ALIAS FOR $14;
  pCurrId ALIAS FOR $15;
  pARAccntId ALIAS FOR $16;

BEGIN
  RETURN createARCreditMemo(NULL, pCustid, pDocNumber, pOrderNumber, pDocDate, pAmount, pNotes, pRsncodeid, pSalescatid, pAccntid, pDueDate, pTermsid, pSalesrepid, pCommissiondue, pJournalNumber, pCurrId, pARAccntId );
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION createARCreditMemo(INTEGER, INTEGER, TEXT, TEXT, DATE, NUMERIC, TEXT, INTEGER, INTEGER, INTEGER, DATE, INTEGER, INTEGER, NUMERIC, INTEGER, INTEGER, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pId ALIAS FOR $1;
  pCustid ALIAS FOR $2;
  pDocNumber ALIAS FOR $3;
  pOrderNumber ALIAS FOR $4;
  pDocDate ALIAS FOR $5;
  pAmount ALIAS FOR $6;
  pNotes ALIAS FOR $7;
  pRsncodeid ALIAS FOR $8;
  pSalescatid ALIAS FOR $9;
  pAccntid ALIAS FOR $10;
  pDueDate ALIAS FOR $11;
  pTermsid ALIAS FOR $12;
  pSalesrepid ALIAS FOR $13;
  pCommissiondue ALIAS FOR $14;
  pJournalNumber ALIAS FOR $15;
  pCurrId ALIAS FOR $16;
  pARAccntid ALIAS FOR $17;
  _custName TEXT;
  _arAccntid INTEGER;
  _prepaidAccntid INTEGER;
  _salescatid INTEGER;
  _accntid INTEGER;
  _glSequence INTEGER;
  _journalNumber INTEGER;
  _aropenid INTEGER;
  _tmp INTEGER;
  _cohistid INTEGER;
  _test INTEGER;
  _taxBaseValue NUMERIC;

BEGIN

  _aropenid := pId;

  IF (pAmount <= 0) THEN
    RETURN 0;
  END IF;

  _arAccntid := COALESCE(pARAccntid, findARAccount(pCustid));
  SELECT findPrepaidAccount(pCustid) INTO _prepaidAccntid;

  _accntid := pAccntid;
  _salescatid := pSalescatid;

  SELECT cust_name INTO _custName
  FROM custinfo
  WHERE (cust_id=pCustid);

  PERFORM accnt_id
     FROM accnt
    WHERE (accnt_id=_accntid);
  IF (FOUND) THEN
    _prepaidAccntid := _accntid;
  ELSE
    _accntid := -1;
  END IF;

  SELECT accnt_id INTO _tmp
    FROM salescat, accnt
   WHERE ((salescat_prepaid_accnt_id=accnt_id)
     AND  (salescat_id=_salescatid));
  IF (FOUND) THEN
    _accntid := -1;
    _prepaidAccntid := _tmp;
  ELSE
    _salescatid = -1;
  END IF;

  IF(pJournalNumber IS NULL) THEN
    SELECT fetchJournalNumber('AR-MISC') INTO _journalNumber;
  ELSE
    _journalNumber := pJournalNumber;
  END IF;

  SELECT fetchGLSequence() INTO _glSequence;

  -- CreatelUpdate aropen for full amount
  IF (_aropenid IS NOT NULL) THEN
    UPDATE aropen SET
      aropen_username=getEffectiveXtUser(), aropen_journalnumber=_journalNumber,
      aropen_cust_id=pCustid, aropen_docnumber=pDocNumber, aropen_doctype='C',
      aropen_ordernumber=pOrderNumber,aropen_docdate=pDocDate, aropen_duedate=pDueDate,
      aropen_distdate=pDocDate, aropen_terms_id=pTermsid,
      aropen_salesrep_id=pSalesrepid, aropen_amount=round(pAmount, 2), aropen_paid=0,
      aropen_commission_due=pCommissiondue, aropen_commission_paid=FALSE,
      aropen_applyto='', aropen_ponumber='', aropen_cobmisc_id=-1,
      aropen_open=TRUE, aropen_notes=pNotes, aropen_rsncode_id=pRsncodeid,
      aropen_salescat_id=_salescatid, aropen_accnt_id=_accntid, aropen_curr_id=pCurrId
    WHERE aropen_id = pId;
  ELSE
    SELECT NEXTVAL('aropen_aropen_id_seq') INTO _aropenid;
    INSERT INTO aropen
    ( aropen_id, aropen_username, aropen_journalnumber,
      aropen_cust_id, aropen_docnumber, aropen_doctype, aropen_ordernumber,
      aropen_docdate, aropen_duedate, aropen_distdate, aropen_terms_id, aropen_salesrep_id,
      aropen_amount, aropen_paid, aropen_commission_due, aropen_commission_paid,
      aropen_applyto, aropen_ponumber, aropen_cobmisc_id,
      aropen_open, aropen_notes, aropen_rsncode_id,
      aropen_salescat_id, aropen_accnt_id, aropen_curr_id )
    VALUES
    ( _aropenid, getEffectiveXtUser(), _journalNumber,
      pCustid, pDocNumber, 'C', pOrderNumber,
      pDocDate, pDueDate, pDocDate, pTermsid, pSalesrepid,
      round(pAmount, 2), 0, pCommissiondue, FALSE,
      '', '', -1,
      TRUE, pNotes, pRsncodeid,
      _salescatid, _accntid, pCurrId );
  END IF;

  -- Credit the A/R account for the full amount
  SELECT insertIntoGLSeries ( _glSequence, 'A/R', 'CM',
                              pDocNumber, _arAccntid,
                              round(currToBase(pCurrId, pAmount, pDocDate), 2),
                              pDocDate, (_custName || ' ' || pNotes)) INTO _test;

  -- Debit the Tax account for the tax amount
  _taxBaseValue := addTaxToGLSeries(_glSequence,
				      'A/R', 'CM', pDocNumber,
				      pCurrId, pDocDate, pDocDate,
                                      'aropentax', _aropenid,
                                      (_custName || ' ' || pNotes));

  UPDATE aropentax SET taxhist_journalnumber = _journalNumber
  WHERE taxhist_parent_id=_aropenid;

  -- Debit the Prepaid account for the basis amount
  -- Note, _taxBaseValue is negative so it is added to pAmount
  SELECT insertIntoGLSeries ( _glSequence, 'A/R', 'CM',
                              pDocNumber, _prepaidAccntid,
                              round(currToBase(pCurrId, pAmount * -1, pDocDate) + _taxBaseValue * -1, 2),
                              pDocDate, (_custName || ' ' || pNotes)) INTO _test;

  --  Commit the GLSeries;
  SELECT postGLSeries(_glSequence, _journalNumber) INTO _test;
  IF (_test < 0) THEN
    DELETE FROM aropen WHERE (aropen_id=_aropenid);
    PERFORM deleteGLSeries(_glSequence);
    RAISE EXCEPTION 'postGLSeries commit failed with %', _test;
  END IF;

  --  Record Sales History
  INSERT INTO cohist
  ( cohist_cust_id,
   cohist_itemsite_id, cohist_shipto_id,
    cohist_misc_type, cohist_misc_descrip,
    cohist_shipdate, cohist_shipvia,
    cohist_ordernumber, cohist_ponumber, cohist_orderdate,
    cohist_doctype, cohist_invcnumber, cohist_invcdate,
    cohist_qtyshipped, cohist_unitprice, cohist_unitcost,
    cohist_salesrep_id,
    cohist_commission, cohist_commissionpaid,
    cohist_curr_id, cohist_sequence )
  VALUES
  (CASE WHEN pCustid < 0 THEN NULL ELSE pCustid END,
   -1, -1,
    'M', 'A/R Misc Credit Memo',
    pDocDate, '',
    '', '', pDocDate,
    'C', pDocNumber, pDocDate,
    1, (pAmount - _taxBaseValue) * -1, 0,
    CASE WHEN pSalesrepid < 0 THEN NULL ELSE pSalesrepid END,
    (pCommissiondue * -1.0), FALSE,
    pCurrId, _glSequence )
  RETURNING cohist_id INTO _cohistid;

  INSERT INTO cohisttax
  ( taxhist_parent_id, taxhist_taxtype_id, taxhist_tax_id,
    taxhist_basis, taxhist_basis_tax_id, taxhist_sequence,
    taxhist_percent, taxhist_amount, taxhist_tax,
    taxhist_docdate, taxhist_distdate, taxhist_curr_id, taxhist_curr_rate,
    taxhist_journalnumber )
  SELECT _cohistid, taxhist_taxtype_id, taxhist_tax_id,
         taxhist_basis, taxhist_basis_tax_id, taxhist_sequence,
         taxhist_percent, taxhist_amount, taxhist_tax,
         taxhist_docdate, taxhist_distdate, taxhist_curr_id, taxhist_curr_rate,
         taxhist_journalnumber
  FROM aropentax
  WHERE (taxhist_parent_id=_aropenid);

  RETURN _aropenid;

END;
$$ LANGUAGE 'plpgsql';
