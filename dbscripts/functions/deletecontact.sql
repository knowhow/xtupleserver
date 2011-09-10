
CREATE OR REPLACE FUNCTION deleteContact(INTEGER) RETURNS INTEGER AS '
  DECLARE
    pcntctId    ALIAS FOR $1;
    _count      INTEGER := 0;
  BEGIN
    SELECT count(*) INTO _count
      FROM crmAcct
      WHERE (crmAcct_active
        AND ((crmacct_cntct_id_1 = pcntctId)
         OR  (crmacct_cntct_id_2 = pcntctId)) );
    IF (_count > 0) THEN
      RETURN -1;
    END IF;

    SELECT count(*) INTO _count
      FROM custinfo
      WHERE (cust_active
        AND ((cust_cntct_id = pcntctId)
         OR  (cust_corrcntct_id = pcntctId)) );
    IF (_count > 0) THEN
      RETURN -2;
    END IF;

    SELECT count(*) INTO _count
      FROM vendinfo
      WHERE (vend_active
        AND ((vend_cntct1_id = pcntctId) OR (vend_cntct2_id = pcntctId)));
    IF (_count > 0) THEN
      RETURN -3;
    END IF;

    SELECT count(*) INTO _count
      FROM shiptoinfo
      WHERE (shipto_active
        AND (shipto_cntct_id = pcntctId));
    IF (_count > 0) THEN
      RETURN -4;
    END IF;

    SELECT count(*) INTO _count
      FROM vendaddrinfo
      WHERE (vendaddr_cntct_id = pcntctId);
    IF (_count > 0) THEN
      RETURN -5;
    END IF;

    SELECT count(*) INTO _count
      FROM whsinfo
      WHERE (warehous_active
        AND (warehous_cntct_id = pcntctId));
    IF (_count > 0) THEN
      RETURN -6;
    END IF;


    UPDATE crmAcct SET crmacct_cntct_id_1 = NULL
      WHERE (crmacct_cntct_id_1 = pcntctId);
    UPDATE crmAcct SET crmacct_cntct_id_2 = NULL
      WHERE (crmacct_cntct_id_2 = pcntctId);
    UPDATE custinfo SET cust_cntct_id = NULL
      WHERE (cust_cntct_id = pcntctId);
    UPDATE custinfo SET cust_corrcntct_id = NULL
      WHERE (cust_corrcntct_id = pcntctId);
    UPDATE vendinfo SET vend_cntct1_id = NULL
      WHERE (vend_cntct1_id = pcntctId);
    UPDATE vendinfo SET vend_cntct2_id = NULL
      WHERE (vend_cntct2_id = pcntctId);
    UPDATE shiptoinfo SET shipto_cntct_id = NULL
      WHERE (shipto_cntct_id = pcntctId);
    UPDATE vendaddrinfo SET vendaddr_cntct_id = NULL
      WHERE (vendaddr_cntct_id = pcntctId);
    UPDATE whsinfo SET warehous_cntct_id = NULL
      WHERE (warehous_cntct_id = pcntctId);

    DELETE FROM cntct WHERE cntct_id = pcntctId;
    RETURN 0;
  END;
' LANGUAGE 'plpgsql';

