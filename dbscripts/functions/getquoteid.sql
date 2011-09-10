CREATE OR REPLACE FUNCTION getQuoteId(text) RETURNS INTEGER AS '
DECLARE
  pQuoteNumber ALIAS FOR $1;
  _returnVal INTEGER;
BEGIN
  IF (pQuoteNumber IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT quhead_id INTO _returnVal
  FROM quhead
  WHERE (quhead_number=pQuoteNumber);

  IF (_returnVal IS NULL) THEN
	RAISE EXCEPTION ''Quote Number % not found.'', pQuoteNumber;
  END IF;

  RETURN _returnVal;
END;
' LANGUAGE 'plpgsql';
