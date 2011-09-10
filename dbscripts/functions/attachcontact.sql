
CREATE OR REPLACE FUNCTION attachContact(INTEGER, INTEGER) RETURNS INTEGER AS '
  DECLARE
    pcntctId    ALIAS FOR $1;
    pcrmacctId  ALIAS FOR $2;
  BEGIN
    UPDATE cntct SET cntct_crmacct_id = pcrmacctId
    WHERE cntct_id = pcntctId;

    RETURN 0;
  END;
' LANGUAGE 'plpgsql';

