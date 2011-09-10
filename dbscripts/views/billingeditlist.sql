SELECT dropIfExists('view', 'billingEditList');

-- Billing header
CREATE VIEW billingEditList AS
SELECT cohead_id AS orderid, -2 AS itemid,
       CASE WHEN (COALESCE(cobmisc_invcnumber, -1) <> -1) THEN ('Invc-' || formatInvcNumber(cobmisc_id))
            ELSE '?'
       END AS documentnumber,
       cust_number, cohead_billtoname AS billtoname,
       cohead_number::TEXT AS ordernumber, -2 AS linenumber,
       '' AS item, '' AS itemdescrip, '' AS iteminvuom,
       CAST(NULL AS NUMERIC) AS qtytobill, '' AS f_qtytobill,
       CAST(NULL AS NUMERIC) AS price, '' AS f_price,
       (calcCobmiscAmt(cobmisc_id) + cobmisc_freight + cobmisc_misc + calcCobmiscTax(cobmisc_id)) AS extprice,
       formatMoney(calcCobmiscAmt(cobmisc_id) + cobmisc_freight + cobmisc_misc + calcCobmiscTax(cobmisc_id)) AS f_extprice,
       'Debit' AS sence,
       COALESCE(formatGLAccountLong(findARAccount(cust_id)), 'Not Assigned') AS account,
       cobmisc_curr_id AS curr_id
FROM cohead, custinfo, cobmisc
WHERE ( (cobmisc_cohead_id=cohead_id)
 AND (cohead_cust_id=cust_id)
 AND (NOT cobmisc_posted) )

-- Billing freight
UNION SELECT cohead_id AS orderid, 0 AS itemid,
             '' AS documentnumber,
             '' AS cust_number, '' AS billtoname,
             cohead_number::TEXT AS ordernumber, 0 AS linenumber,
             'Freight' AS item, 'Freight Charge' AS itemdescrip, '' AS iteminvuom,
             NULL AS qtytobill, '' AS f_qtytobill,
             cobmisc_freight AS price, formatMoney(cobmisc_freight) AS f_price,
             cobmisc_freight AS extprice, formatMoney(cobmisc_freight) AS f_extprice,
             'Credit' AS sence,
             COALESCE(formatGLAccountLong(findFreightAccount(cohead_cust_id)), 'Not Assigned') AS account,
             cobmisc_curr_id AS curr_id
FROM cobmisc, cohead
WHERE ( (cobmisc_cohead_id=cohead_id)
 AND (NOT cobmisc_posted)
 AND (cobmisc_freight <> 0) )

-- Billing misc charges
UNION SELECT cohead_id AS orderid, 0 AS itemid,
             '' AS documentnumber,
             '' AS cust_number, '' AS billtoname,
             cohead_number::TEXT AS ordernumber, -1 AS linenumber,
             'Misc. Charge' AS item, cohead_misc_descrip AS itemdescrip, '' AS iteminvuom,
             NULL AS qtytobill, '' AS f_qtytobill,
             cobmisc_misc AS price, formatMoney(cobmisc_misc) AS f_price,
             cobmisc_misc AS extprice, formatMoney(cobmisc_misc) AS f_extprice,
             'Credit' AS sence,
             formatGLAccountLong(cobmisc_misc_accnt_id) AS account,
             cobmisc_curr_id AS curr_id
FROM cobmisc, cohead
WHERE ( (cobmisc_cohead_id=cohead_id)
 AND (NOT cobmisc_posted)
 AND (cobmisc_misc <> 0) )

-- Billing tax
UNION SELECT cohead_id AS orderid, 0 AS itemid,
             '' AS documentnumber,
             '' AS cust_number, '' AS billtoname,
             cohead_number::TEXT AS ordernumber, -2 AS linenumber,
             'Tax' AS item, '' AS itemdescrip, '' AS iteminvuom,
             NULL AS qtytobill, '' AS f_qtytobill,
             calcCobmiscTax(cobmisc_id) AS price, formatMoney(calcCobmiscTax(cobmisc_id)) AS f_price,
             calcCobmiscTax(cobmisc_id) AS extprice, formatMoney(calcCobmiscTax(cobmisc_id)) AS f_extprice,
             'Credit' AS sence,
             '' AS account,
             cobmisc_curr_id AS curr_id
FROM cobmisc, cohead
WHERE ( (cobmisc_cohead_id=cohead_id)
 AND (NOT cobmisc_posted) )

-- Billing lines
UNION SELECT cohead_id AS orderid, coitem_id AS itemid,
             '' AS documentnumber,
             '' AS cust_number,
             '' AS billtoname,
             cohead_number::TEXT AS ordernumber, coitem_linenumber AS linenumber,
             item_number AS item, item_descrip1 AS itemdescrip, uom_name AS iteminvuom,
             cobill_qty AS qtytobill, formatQty(cobill_qty) AS f_qtytobill,
             coitem_price AS price, formatPrice(coitem_price) AS f_price,
             calcCobillAmt(cobill_id) AS extprice,
             formatMoney(calcCobillAmt(cobill_id)) AS f_extprice,
             'Credit' AS sence,
             COALESCE( ( SELECT formatGLAccountLong(salesaccnt_sales_accnt_id)
                         FROM salesaccnt
                         WHERE (salesaccnt_id=findSalesAccnt(itemsite_id, cohead_cust_id)) ), 'Not Assigned') AS account,
             cobmisc_curr_id AS curr_id
FROM item, itemsite, cobmisc, cohead, cobill, coitem, uom
WHERE ( (coitem_itemsite_id=itemsite_id)
 AND (cobill_coitem_id=coitem_id)
 AND (cobill_cobmisc_id=cobmisc_id)
 AND (cobmisc_cohead_id=cohead_id)
 AND (itemsite_item_id=item_id)
 AND (item_inv_uom_id=uom_id)
 AND (cobill_cobmisc_id=cobmisc_id)
 AND (NOT cobmisc_posted) )

ORDER BY ordernumber, linenumber;

REVOKE ALL ON billingEditList FROM PUBLIC;
GRANT ALL ON billingEditList TO GROUP xtrole;

