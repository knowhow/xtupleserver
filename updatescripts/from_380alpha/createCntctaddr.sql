--drop table cntctaddr
create table cntctaddr (
  cntctaddr_id serial primary key,
  cntctaddr_cntct_id integer references cntct (cntct_id) on delete cascade,
  cntctaddr_primary boolean not null,
  cntctaddr_addr_id integer not null references addr (addr_id),
  cntctaddr_type char(2) not null
);

grant all on table cntctaddr to xtrole;
grant all on table cntctaddr_cntctaddr_id_seq to xtrole;