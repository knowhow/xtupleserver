SELECT dropIfExists('FUNCTION', 'apaging(date, boolean)', 'public');

CREATE OR REPLACE FUNCTION apaging(date, boolean) RETURNS SETOF apaging AS $$
DECLARE
  pAsOfDate ALIAS FOR $1;
  pUseDocDate ALIAS FOR $2;
  _row apaging%ROWTYPE;
  _x RECORD;
  _returnVal INTEGER;
  _asOfDate DATE;
BEGIN

  _asOfDate := COALESCE(pAsOfDate,current_date);

  FOR _x IN
        SELECT
        --report uses currency rate snapshot to convert all amounts to base based on apopen_docdate to ensure the same exchange rate

        --today and greater base:
        CASE WHEN((apopen_duedate >= DATE(_asOfDate)))
        THEN (((apopen_amount-apopen_paid+COALESCE(SUM(apapply_target_paid),0)))/apopen_curr_rate *
        CASE WHEN (apopen_doctype IN ('D', 'V')) THEN 1 ELSE -1 END) ELSE 0 END AS cur_val,

        --0 to 30 base
        CASE WHEN((apopen_duedate >= DATE(_asOfDate)-30) AND (apopen_duedate < DATE(_asOfDate)))
        THEN (((apopen_amount-apopen_paid+COALESCE(SUM(apapply_target_paid),0)))/apopen_curr_rate *
        CASE WHEN (apopen_doctype IN ('D', 'V')) THEN 1 ELSE -1 END) ELSE 0 END AS thirty_val,

        --30-60 base
        CASE WHEN((apopen_duedate >= DATE(_asOfDate)-60) AND (apopen_duedate < DATE(_asOfDate) - 30 ))
        THEN (((apopen_amount-apopen_paid+COALESCE(SUM(apapply_target_paid),0)))/apopen_curr_rate *
        CASE WHEN (apopen_doctype IN ('D', 'V')) THEN 1 ELSE -1 END) ELSE 0 END AS sixty_val,

        --60-90 base
        CASE WHEN((apopen_duedate >= DATE(_asOfDate)-90) AND (apopen_duedate < DATE(_asOfDate) - 60))
        THEN (((apopen_amount-apopen_paid+COALESCE(SUM(apapply_target_paid),0)))/apopen_curr_rate *
        CASE WHEN (apopen_doctype IN ('D', 'V')) THEN 1 ELSE -1 END) ELSE 0 END AS ninety_val,

        --greater than 90 base:
        CASE WHEN((apopen_duedate > DATE(_asOfDate)-10000) AND (apopen_duedate < DATE(_asOfDate) - 90))
        THEN (((apopen_amount-apopen_paid + COALESCE(SUM(apapply_target_paid),0)))/apopen_curr_rate *
        CASE WHEN (apopen_doctype IN ('D', 'V')) THEN 1 ELSE -1 END) ELSE 0 END AS plus_val,

        --total amount base:
        CASE WHEN((apopen_duedate > DATE(_asOfDate)-10000))
        THEN (((apopen_amount-apopen_paid+COALESCE(SUM(apapply_target_paid),0)))/apopen_curr_rate *
        CASE WHEN (apopen_doctype IN ('D', 'V')) THEN 1 ELSE -1 END) ELSE 0 END AS total_val,

        --AP Open Amount base
        CASE WHEN apopen_doctype IN ('C', 'R') 
        THEN (apopen_amount * -1) / apopen_curr_rate
        ELSE apopen_amount / apopen_curr_rate END AS apopen_amount,
        
        apopen_docdate,
        apopen_duedate,
        apopen_ponumber,
        apopen_invcnumber,
        apopen_docnumber,
        apopen_doctype,
        vend_id,
        vend_name,
        vend_number,
        vend_vendtype_id,
        vendtype_code,
        terms_descrip,
        determineDiscountDate(terms_id, apopen_docdate) AS discdate,
        noNeg(apopen_discountable_amount *
                     CASE WHEN (CURRENT_DATE <= determineDiscountDate(terms_id, apopen_docdate)) THEN terms_discprcnt
                     ELSE 0.0 END) AS disc_val,
        terms_discdays AS discdays,
        (terms_discprcnt * 100.0) AS discprcnt

        FROM vendinfo, vendtype, apopen
          LEFT OUTER JOIN terms ON (apopen_terms_id=terms_id)
          LEFT OUTER JOIN apapply ON (((apopen_id=apapply_target_apopen_id)
                                    OR (apopen_id=apapply_source_apopen_id))
                                   AND (apapply_postdate >_asOfDate))
        WHERE ( (apopen_vend_id = vend_id)
        AND (vend_vendtype_id=vendtype_id)
        AND (CASE WHEN (pUseDocDate) THEN apopen_docdate ELSE apopen_distdate END <= _asOfDate)
        AND (COALESCE(apopen_closedate,_asOfDate+1)>_asOfDate) )
        GROUP BY apopen_id,apopen_docdate,apopen_duedate,apopen_ponumber, apopen_invcnumber, apopen_docnumber,apopen_doctype,apopen_paid,
                 apopen_curr_id,apopen_amount,vend_id,vend_name,vend_number,vend_vendtype_id,vendtype_code,terms_descrip,
                 apopen_curr_rate, terms_id, terms_discdays, terms_discprcnt, apopen_discountable_amount
        ORDER BY vend_number, apopen_duedate
  LOOP
        _row.apaging_docdate := _x.apopen_docdate;
        _row.apaging_duedate := _x.apopen_duedate;
        _row.apaging_ponumber := _x.apopen_ponumber;
        _row.apaging_invcnumber := _x.apopen_invcnumber;
        _row.apaging_docnumber := _x.apopen_docnumber;
        _row.apaging_doctype := _x.apopen_doctype;
        _row.apaging_vend_id := _x.vend_id;
        _row.apaging_vend_number := _x.vend_number;
        _row.apaging_vend_name := _x.vend_name;
        _row.apaging_vend_vendtype_id := _x.vend_vendtype_id;
        _row.apaging_vendtype_code := _x.vendtype_code;
        _row.apaging_terms_descrip := _x.terms_descrip;
        _row.apaging_apopen_amount := _x.apopen_amount;
        _row.apaging_cur_val := _x.cur_val;
        _row.apaging_thirty_val := _x.thirty_val;
        _row.apaging_sixty_val := _x.sixty_val;
        _row.apaging_ninety_val := _x.ninety_val;
        _row.apaging_plus_val := _x.plus_val;
        _row.apaging_total_val := _x.total_val;
        _row.apaging_discdate := _x.discdate;
        _row.apaging_disc_val := _x.disc_val;
        _row.apaging_discdays := _x.discdays;
        _row.apaging_discprcnt := _x.discprcnt;
        RETURN NEXT _row;
  END LOOP;
  RETURN;
END;
$$ LANGUAGE 'plpgsql';
