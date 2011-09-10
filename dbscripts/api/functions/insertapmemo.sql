
CREATE OR REPLACE FUNCTION insertapmemo(api.apmemo) RETURNS boolean AS $$
DECLARE
  pNew ALIAS FOR $1;
  _result INTEGER;

BEGIN
  IF (pNew.document_type = 'Credit Memo') THEN
    SELECT createAPCreditMemo( getVendId(pNew.vendor_number),
                               pNew.document_number,
                               pNew.po_number,
                               pNew.document_date,
                               pNew.amount,
                               pNew.notes,
                               getGLAccntId(pNew.alternate_prepaid_account),
                               pNew.due_date,
                               getTermsId(pNew.terms) ) INTO _result;
    IF (_result <= 0) THEN
      RAISE EXCEPTION 'Function createAPCreditMemo failed with result = %', _result;
    END IF;
  ELSE
    IF (pNew.document_type = 'Debit Memo') THEN
      SELECT createAPDebitMemo( null, getVendId(pNew.vendor_number),
                                pNew.journal_number,
                                pNew.document_number,
                                pNew.po_number,
                                pNew.document_date,
                                pNew.amount,
                                pNew.notes,
                                getGLAccntId(pNew.alternate_prepaid_account),
                                pNew.due_date,
                                getTermsId(pNew.terms),
                                COALESCE(getCurrId(pNew.currency), baseCurrId()) ) INTO _result;
      IF (_result <= 0) THEN
        RAISE EXCEPTION 'Function createAPDebitMemo failed with result = %', _result;
      END IF;
    ELSE
      RAISE EXCEPTION 'Function insertAPMemo failed, invalid Document Type';
    END IF;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';

