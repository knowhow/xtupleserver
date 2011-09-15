CREATE TABLE mrgundo (
  mrgundo_base_schema TEXT,
  mrgundo_base_table  TEXT,
  mrgundo_base_id     INTEGER,
  mrgundo_schema      TEXT,
  mrgundo_table       TEXT,
  mrgundo_pkey_col    TEXT,
  mrgundo_pkey_id     INTEGER,
  mrgundo_col         TEXT,
  mrgundo_value       TEXT,
  mrgundo_type        TEXT,

  UNIQUE (
    mrgundo_schema,
    mrgundo_table,
    mrgundo_pkey_col,
    mrgundo_pkey_id,
    mrgundo_col
  )
);

GRANT ALL ON TABLE mrgundo TO xtrole;

COMMENT ON TABLE mrgundo IS 'This table keeps track of the original values of changes made while merging two records. It is a generalization of mrghist and trgthist, which are specific to merging contacts. The schema, table, and pkey_id columns uniquely identify the record that was changed while the _base_ columns identify the merge target. The _base_ columns are required to allow finding all of the records that pertain to a particular merge (e.g. find changes to the comment table that pertain to a crmacct merge).';
COMMENT ON COLUMN mrgundo.mrgundo_base_schema IS 'The schema in which the merge target resides.';
COMMENT ON COLUMN mrgundo.mrgundo_base_table IS 'The table in which the merge target resides.';
COMMENT ON COLUMN mrgundo.mrgundo_base_id IS 'The internal id of the merge target record.';
COMMENT ON COLUMN mrgundo.mrgundo_schema IS 'The name of the schema in which the modified table resides.';
COMMENT ON COLUMN mrgundo.mrgundo_table IS 'The name of the table that was modified during a merge.';
COMMENT ON COLUMN mrgundo.mrgundo_pkey_col IS 'The name of the primary key column in the modified table. This could be derived during the undo processing but it is simpler just to store it during the merge.';
COMMENT ON COLUMN mrgundo.mrgundo_pkey_id IS 'The primary key of the modified record.';
COMMENT ON COLUMN mrgundo.mrgundo_col IS 'The column that was modified.';
COMMENT ON COLUMN mrgundo.mrgundo_value IS 'The value of the column before the change.';
COMMENT ON COLUMN mrgundo.mrgundo_type IS 'The data type of the modified column. This could be derived during the undo processing but it is simpler just to store it during the merge.';
