CREATE OR REPLACE FUNCTION setCCBankAccnt(TEXT, INTEGER) RETURNS INTEGER AS $$
DECLARE
  pccardtype   ALIAS FOR $1;
  pbankaccntid ALIAS FOR $2;

  _ccbankid    INTEGER;
  _numfound    INTEGER;

BEGIN
  RAISE DEBUG 'setCCBankAccount(%, %) entered', pccardtype, pbankaccntid;
  UPDATE ccbank SET ccbank_bankaccnt_id=pbankaccntid
  WHERE ccbank_ccard_type=pccardtype
  RETURNING ccbank_id INTO _ccbankid;

  GET DIAGNOSTICS _numfound = ROW_COUNT;

  IF (_numfound <= 0) THEN
    INSERT INTO ccbank (ccbank_ccard_type, ccbank_bankaccnt_id)
                VALUES (pccardtype,        pbankaccntid)
    RETURNING _ccbankid;
  END IF;

  RETURN _ccbankid;
END;
$$ LANGUAGE 'plpgsql';
