--drop table cntctdata
create table cntctdata (
  cntctdata_id serial primary key,
  cntctdata_cntct_id integer references cntct (cntct_id) on delete cascade,
  cntctdata_primary boolean not null,
  cntctdata_text text not null,
  cntctdata_type char(2) not null
);

grant all on table cntctdata to xtrole;
grant all on table cntctdata_cntctdata_id_seq to xtrole;