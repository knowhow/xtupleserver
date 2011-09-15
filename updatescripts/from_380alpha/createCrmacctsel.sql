CREATE TABLE crmacctsel
(
  crmacctsel_src_crmacct_id     INTEGER PRIMARY KEY
                                        REFERENCES crmacct (crmacct_id)
                                        ON DELETE CASCADE,
  crmacctsel_dest_crmacct_id    INTEGER REFERENCES crmacct (crmacct_id)
                                        ON DELETE CASCADE,

  crmacctsel_mrg_crmacct_active	        BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_cntct_id_1	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_cntct_id_2	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_competitor_id	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_cust_id	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_emp_id	        BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_name	        BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_notes	        BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_owner_username	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_parent_id	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_partner_id	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_prospect_id	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_salesrep_id	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_taxauth_id	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_type	        BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_usr_username	BOOLEAN NOT NULL DEFAULT false,
  crmacctsel_mrg_crmacct_vend_id	BOOLEAN NOT NULL DEFAULT false

);

GRANT ALL ON TABLE crmacctsel TO xtrole;

COMMENT ON TABLE crmacctsel IS 'This table records the proposed conditions of a CRM Account merge. When this merge is performed, the BOOLEAN columns in this table indicate which values in the crmacct table will be copied to the target record. Data in this table are temporary and will be removed by a purge.';
COMMENT ON COLUMN crmacctsel.crmacctsel_src_crmacct_id IS 'This is the internal ID of the CRM Account record the data will come from during the merge.';
COMMENT ON COLUMN crmacctsel.crmacctsel_dest_crmacct_id IS 'This is the internal ID of the CRM Account record the data will go to during the merge. If crmacctsel_src_crmacct_id = crmacctsel_dest_crmacct_id, they indicate which crmacct record is the destination of the merge, meaning this is the record that will remain in the database after the merge has been completed and the intermediate data have been purged.';
