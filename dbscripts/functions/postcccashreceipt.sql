CREATE OR REPLACE FUNCTION postCCcashReceipt(INTEGER, INTEGER) RETURNS INTEGER AS $$
BEGIN
  RETURN postCCCashReceipt($1, NULL, NULL);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION postCCcashReceipt(INTEGER, INTEGER, TEXT) RETURNS INTEGER AS
$$
DECLARE
  pCCpay        ALIAS FOR $1;
  pdocid        ALIAS FOR $2;
  pdoctype      ALIAS FOR $3;
  _aropenid     INTEGER;
  _bankaccnt_id INTEGER;
  _c            RECORD;
  _cashrcptid   INTEGER;
  _ccOrderDesc  TEXT;
  _realaccnt    INTEGER;
  _return       INTEGER := 0;

BEGIN
  SELECT * INTO _c
     FROM ccpay, ccard, custinfo
     WHERE ( (ccpay_id = pCCpay)
       AND   (ccpay_ccard_id = ccard_id)
       AND   (ccpay_cust_id = cust_id) );

  IF (NOT FOUND) THEN
    RETURN -11;
  END IF;

  SELECT bankaccnt_id, bankaccnt_accnt_id INTO _bankaccnt_id, _realaccnt
  FROM ccbank JOIN bankaccnt ON (ccbank_bankaccnt_id=bankaccnt_id)
  WHERE (ccbank_ccard_type=_c.ccard_type);

  IF (NOT FOUND) THEN
    RETURN -10;
  END IF;

  _ccOrderDesc := (_c.ccard_type || '-' || _c.ccpay_order_number::TEXT ||
		   '-' || _c.ccpay_order_number_seq::TEXT);

  IF (pdoctype = 'cashrcpt') THEN
    IF (COALESCE(pdocid, -1) < 0) THEN
      _cashrcptid := NEXTVAL('cashrcpt_cashrcpt_id_seq');
      INSERT INTO cashrcpt (
        cashrcpt_id, cashrcpt_cust_id,   cashrcpt_amount,     cashrcpt_curr_id,
        cashrcpt_fundstype, cashrcpt_docnumber,  cashrcpt_notes,
        cashrcpt_distdate,  cashrcpt_bankaccnt_id
      ) VALUES (
        _cashrcptid, _c.ccpay_cust_id,   _c.ccpay_amount,     _c.ccpay_curr_id,
        _c.ccard_type,      _c.ccpay_r_ordernum, _ccOrderDesc,
        CURRENT_DATE,       _bankaccnt_id);
      _return := _cashrcptid;
    ELSE
      UPDATE cashrcpt
      SET cashrcpt_cust_id=_c.ccpay_cust_id,
          cashrcpt_amount=_c.ccpay_amount,
          cashrcpt_curr_id=_c.ccpay_curr_id,
          cashrcpt_fundstype=_c.ccard_type,
          cashrcpt_docnumber=_c.ccpay_r_ordernum,
          cashrcpt_notes=_ccOrderDesc,
          cashrcpt_distdate=CURRENT_DATE,
          cashrcpt_bankaccnt_id=_bankaccnt_id
      WHERE (cashrcpt_id=pdocid);
      _return := pdocid;
    END IF;

  ELSIF (pdoctype = 'cohead') THEN
    _aropenid := createARCreditMemo(_c.ccpay_cust_id, fetchArMemoNumber(),
                                    '', CURRENT_DATE, _c.ccpay_amount,
                                    'Unapplied from ' || _ccOrderDesc );
    IF (_aropenid < 0) THEN
      RETURN _aropenid;
    END IF;

    INSERT INTO payaropen (payaropen_ccpay_id, payaropen_aropen_id,
                           payaropen_amount,   payaropen_curr_id)
                  VALUES  (pccpay,             _aropenid,
                           _c.ccpay_amount,    _c.ccpay_curr_id);
    INSERT INTO aropenalloc (aropenalloc_aropen_id, aropenalloc_doctype, aropenalloc_doc_id,
                             aropenalloc_amount,    aropenalloc_curr_id)
                     VALUES (_aropenid, 'S',          pdocid,
                             _c.ccpay_amount,    _c.ccpay_curr_id);
    _return := _aropenid;
  END IF;

  PERFORM insertGLTransaction(fetchJournalNumber('C/R'), 'A/R', 'CR',
                              _ccOrderDesc, 
                              ('Cash Receipt from Credit Card ' || _c.cust_name),
                              findPrepaidAccount(_c.ccpay_cust_id),
                              _realaccnt,
                              NULL,
			      ROUND(currToBase(_c.ccpay_curr_id,
					       _c.ccpay_amount,
					       _c.ccpay_transaction_datetime::DATE),2),
                              CURRENT_DATE);

  RETURN _return;
END;
$$ LANGUAGE 'plpgsql';
