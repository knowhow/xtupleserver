CREATE OR REPLACE FUNCTION getCmheadId(text) RETURNS INTEGER AS '
DECLARE
  pCreditMemoNumber ALIAS FOR $1;
BEGIN
  RETURN getCmheadId(pCreditMemoNumber, NULL);
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION getCmheadId(text, boolean) RETURNS INTEGER AS '
DECLARE
  pCreditMemoNumber ALIAS FOR $1;
  pPosted ALIAS FOR $2;
  _returnVal INTEGER;
BEGIN
  IF (pCreditMemoNumber IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT cmhead_id INTO _returnVal
  FROM cmhead
  WHERE (UPPER(cmhead_number)=UPPER(pCreditMemoNumber))
    AND ((pPosted IS NULL) OR (cmhead_posted=pPosted));

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Credit Memo % not found.'', pCreditMemoNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
