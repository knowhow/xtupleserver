CREATE OR REPLACE FUNCTION postCCcredit(INTEGER, TEXT, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pCCpay	ALIAS FOR $1;
  preftype      ALIAS FOR $2;
  prefid        ALIAS FOR $3;
  _amountclosed NUMERIC;
  _c		RECORD;
  _ccOrderDesc	TEXT;
  _closed       BOOLEAN;
  _cglaccnt     INTEGER;
  _dglaccnt	INTEGER;
  _journalNum	INTEGER;
  _notes	TEXT := 'Credit Customer via Credit Card';
  _r		aropen%ROWTYPE;
  _sequence	INTEGER;
  _dmaropenid	INTEGER;

BEGIN
  IF ((preftype = 'cohead') AND NOT EXISTS(SELECT cohead_id
					     FROM cohead
					     WHERE (cohead_id=prefid))) THEN
    RETURN -2;
  ELSIF ((preftype = 'aropen') AND NOT EXISTS(SELECT aropen_id
                                                FROM aropen
                                                WHERE (aropen_id=prefid))) THEN
    RETURN -2;
  END IF;

  SELECT * INTO _c
     FROM ccpay
     JOIN ccard  ON (ccpay_ccard_id = ccard_id)
     JOIN ccbank ON (ccard_type=ccbank_ccard_type)
    WHERE (ccpay_id = pCCpay);

  IF (NOT FOUND) THEN
    RETURN -3;
  END IF;

  IF (preftype = 'cohead') THEN
    _dglaccnt := findPrepaidAccount(_c.ccpay_cust_id);
  ELSE
    _dglaccnt := findARAccount(_c.ccpay_cust_id);
  END IF;

  SELECT bankaccnt_accnt_id INTO _cglaccnt
  FROM bankaccnt
  WHERE (bankaccnt_id=_c.ccbank_bankaccnt_id);

  IF (NOT FOUND) THEN
    RETURN -1;
  END IF;

  IF (_c.ccpay_type != 'R') THEN
    RETURN -4;
  END IF;

  _sequence := fetchGLSequence();

  IF (_c.ccpay_r_ref IS NOT NULL) THEN
    _ccOrderDesc := (_c.ccard_type || '-' || _c.ccpay_r_ref);
  ELSE
    _ccOrderDesc := (_c.ccard_type || '-' || _c.ccpay_order_number::TEXT ||
		     '-' || COALESCE(_c.ccpay_order_number_seq::TEXT, ''));
  END IF;

  PERFORM insertIntoGLSeries(_sequence, 'A/R', 'CC', _ccOrderDesc,
			     _dglaccnt,
			     ROUND(currToBase(_c.ccpay_curr_id,
					      _c.ccpay_amount,
					      _c.ccpay_transaction_datetime::DATE), 2) * -1,
			     CURRENT_DATE, _notes );

  PERFORM insertIntoGLSeries( _sequence, 'A/R', 'CC', _ccOrderDesc,
			      _cglaccnt,
			      ROUND(currToBase(_c.ccpay_curr_id,
					       _c.ccpay_amount,
					       _c.ccpay_transaction_datetime::DATE),2),
			      CURRENT_DATE, _notes );

  PERFORM postGLSeries(_sequence, fetchJournalNumber('C/R') );

  IF (preftype = 'aropen') THEN
    SELECT * INTO _r
    FROM aropen
    WHERE (aropen_id=prefid);

  ELSE
    SELECT aropen.* INTO _r
    FROM ccpay n
      JOIN ccpay o  ON (o.ccpay_id=n.ccpay_ccpay_id)
      JOIN payaropen ON (payaropen_ccpay_id=o.ccpay_id)
      JOIN aropen ON (payaropen_aropen_id=aropen_id)
    WHERE (n.ccpay_id=pCCpay);
  END IF;

  IF (FOUND) THEN
  -- create debit memo for refund that offsets original credit memo
    SELECT createardebitmemo(
            NULL, 
            _r.aropen_cust_id, NULL, fetchARMemoNumber(),
            _r.aropen_ordernumber, current_date, _r.aropen_amount,
            'Reverse credit for voided Sales Order',
            -1, -1, -1, CURRENT_DATE, -1, NULL, 0, 
            _r.aropen_curr_id) INTO _dmaropenid;

    -- See if the original credit memo is still open
    IF (_r.aropen_open) THEN
      -- Apply original as much of  orignial credit memo to new debit memo as possible
      PERFORM applyARCreditMemoToBalance(_r.aropen_id, _dmaropenid);
      PERFORM postARCreditMemoApplication(_r.aropen_id);
    END IF;
    
  END IF;

  IF (preftype = 'cohead') THEN
    INSERT INTO payco (
      payco_ccpay_id, payco_cohead_id, payco_amount, payco_curr_id 
    ) VALUES (
      pCCpay, prefid, 0 - _c.ccpay_amount, _c.ccpay_curr_id
    );
  END IF;

  RETURN 0;

END;
$$
LANGUAGE 'plpgsql';
