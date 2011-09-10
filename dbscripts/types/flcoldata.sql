select dropifexists('FUNCTION', 'getflcoldata(int,int)');
select dropifexists('TYPE', 'flcoldata');
CREATE TYPE flcoldata AS (
  flcoldata_column  	INTEGER,
  flcoldata_start   	DATE,
  flcoldata_end        DATE
);
