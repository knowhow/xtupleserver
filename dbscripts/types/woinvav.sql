
SELECT dropIfExists('TYPE', 'woinvav');

CREATE TYPE woinvav AS
   (woinvav_itemsite_id integer,
    woinvav_womatl_id integer,
    woinvav_type character(1),
    woinvav_item_wo_number text,
    woinvav_descrip text,
    woinvav_uomname text,
    woinvav_qoh numeric,
    woinvav_balance numeric,
    woinvav_allocated numeric,
    woinvav_ordered numeric,
    woinvav_woavail numeric,
    woinvav_totalavail numeric,
    woinvav_reorderlevel numeric,
    woinvav_level integer);

