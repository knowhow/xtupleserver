CREATE OR REPLACE VIEW api.apmemo AS 
 SELECT vendinfo.vend_number AS vendor_number, apopen.apopen_docdate AS document_date, apopen.apopen_duedate AS due_date, 
        CASE
            WHEN apopen.apopen_doctype = 'C'::bpchar THEN 'Credit Memo'::text
            ELSE 'Debit Memo'::text
        END AS document_type, apopen.apopen_docnumber AS document_number, apopen.apopen_ponumber AS po_number, apopen.apopen_journalnumber AS journal_number, terms.terms_code AS terms, curr.curr_abbr AS currency, apopen.apopen_amount AS amount, apopen.apopen_paid AS paid, apopen.apopen_amount - apopen.apopen_paid AS balance, apopen.apopen_notes AS notes, 
        CASE
            WHEN apopen.apopen_accnt_id = (-1) THEN NULL::text
            ELSE formatglaccount(apopen.apopen_accnt_id)
        END AS alternate_prepaid_account
   FROM apopen
   LEFT JOIN vendinfo ON vendinfo.vend_id = apopen.apopen_vend_id
   LEFT JOIN curr_symbol curr ON curr.curr_id = apopen.apopen_curr_id
   LEFT JOIN terms ON terms.terms_id = apopen.apopen_terms_id
  WHERE apopen.apopen_doctype = ANY (ARRAY['C'::bpchar, 'D'::bpchar]);

GRANT ALL ON TABLE api.apmemo TO xtrole;
COMMENT ON VIEW api.apmemo IS 'A/P Credit and Debit Memo';


CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO api.apmemo DO INSTEAD  SELECT insertapmemo(new.*) AS insertapmemo;

CREATE OR REPLACE RULE "_UPDATE" AS
    ON UPDATE TO api.apmemo DO INSTEAD  UPDATE apopen SET apopen_duedate = new.due_date, apopen_terms_id = gettermsid(new.terms), apopen_amount = new.amount, apopen_notes = new.notes
  WHERE apopen.apopen_docnumber = old.document_number AND apopen.apopen_doctype::text = 
        CASE
            WHEN old.document_type = 'Credit Memo'::text THEN 'C'::text
            WHEN old.document_type = 'Debit Memo'::text THEN 'D'::text
            ELSE ''::text
        END;

CREATE OR REPLACE RULE "_RETURN" AS
    ON SELECT TO api.apmemo DO INSTEAD  SELECT vendinfo.vend_number AS vendor_number, apopen.apopen_docdate AS document_date, apopen.apopen_duedate AS due_date, 
        CASE
            WHEN apopen.apopen_doctype = 'C'::bpchar THEN 'Credit Memo'::text
            ELSE 'Debit Memo'::text
        END AS document_type, apopen.apopen_docnumber AS document_number, apopen.apopen_ponumber AS po_number, apopen.apopen_journalnumber AS journal_number, terms.terms_code AS terms, curr.curr_abbr AS currency, apopen.apopen_amount AS amount, apopen.apopen_paid AS paid, apopen.apopen_amount - apopen.apopen_paid AS balance, apopen.apopen_notes AS notes, 
        CASE
            WHEN apopen.apopen_accnt_id = (-1) THEN NULL::text
            ELSE formatglaccount(apopen.apopen_accnt_id)
        END AS alternate_prepaid_account
   FROM apopen
   LEFT JOIN vendinfo ON vendinfo.vend_id = apopen.apopen_vend_id
   LEFT JOIN curr_symbol curr ON curr.curr_id = apopen.apopen_curr_id
   LEFT JOIN terms ON terms.terms_id = apopen.apopen_terms_id
  WHERE apopen.apopen_doctype = ANY (ARRAY['C'::bpchar, 'D'::bpchar]);

CREATE OR REPLACE RULE "_DELETE" AS
    ON DELETE TO api.apmemo DO INSTEAD NOTHING;
