SELECT dropIfExists('view', 'voucheringEditList');
CREATE VIEW voucheringEditList AS
SELECT vend_id AS vendid, vohead_id AS orderid, 1 AS itemid,
       vohead_number AS vouchernumber, COALESCE(TEXT(pohead_number), 'Misc.') AS ponumber,
       vohead_invcnumber AS invoicenumber, vend_number AS itemnumber, vend_name AS description,
       vendtype_code AS itemtype, '' AS iteminvuom, '' AS f_qty,
       SUM(vodist_amount) + calcVoucherFreight(vohead_id) AS cost,
        formatMoney(SUM(vodist_amount) + calcVoucherFreight(vohead_id)) AS f_cost,
       '' AS account
FROM vodist, vendinfo, vendtype, vohead LEFT OUTER JOIN pohead ON (vohead_pohead_id=pohead_id)
WHERE ( (vodist_vohead_id=vohead_id)
 AND (vohead_vend_id=vend_id)
 AND (vend_vendtype_id=vendtype_id)
 AND (NOT vohead_posted) )
GROUP BY vend_id, vohead_id, vohead_number, pohead_number, vohead_invcnumber, vend_number, vend_name, vendtype_code

UNION ALL SELECT vohead_vend_id AS vendid, vohead_id AS orderid, 2 AS itemid,
             vohead_number AS vouchernumber, '' AS ponumber, '' AS invoicenumber,
             item_number AS itemnumber, (item_descrip1 || ' ' || item_descrip2) AS description,
             '' AS itemtype, uom_name AS iteminvuom, formatQty(vodist_qty) AS f_qty,
             vodist_amount AS cost, formatMoney(vodist_amount) AS f_cost,
             CASE WHEN (accnt_id IS NULL) THEN 'Not Assigned'
                  ELSE formatGLAccountLong(accnt_id)
             END AS account
FROM vohead, vodist, poitem, item, uom,
     itemsite LEFT OUTER JOIN
     ( costcat LEFT OUTER JOIN accnt
       ON (costcat_liability_accnt_id=accnt_id)
     ) ON (itemsite_costcat_id=costcat_id)
WHERE ( (vodist_vohead_id=vohead_id)
 AND (vodist_poitem_id<>-1)
 AND (vodist_poitem_id=poitem_id)
 AND (poitem_itemsite_id=itemsite_id)
 AND (itemsite_item_id=item_id)
 AND (item_inv_uom_id=uom_id)
 AND (NOT vohead_posted) )

-- Freight
UNION ALL SELECT vohead_vend_id AS vendid, vohead_id AS orderid, 2 AS itemid,
             vohead_number AS vouchernumber, '' AS ponumber, '' AS invoicenumber,
             'Freight' AS itemnumber, 'Freight Charge' AS description,
             '' AS itemtype, '' AS iteminvuom, '' AS f_qty,
             voitem_freight AS cost, formatMoney(voitem_freight) AS f_cost,
             CASE WHEN (accnt_id IS NULL) THEN 'Not Assigned'
                  ELSE formatGLAccountLong(accnt_id)
             END AS account
FROM vohead, voitem, poitem, item, uom,
     itemsite LEFT OUTER JOIN
     ( costcat LEFT OUTER JOIN accnt
       ON (costcat_liability_accnt_id=accnt_id)
     ) ON (itemsite_costcat_id=costcat_id)
WHERE ( (voitem_vohead_id=vohead_id)
 AND (voitem_poitem_id<>-1)
 AND (voitem_poitem_id=poitem_id)
 AND (poitem_itemsite_id=itemsite_id)
 AND (itemsite_item_id=item_id)
 AND (item_inv_uom_id=uom_id)
 AND (NOT vohead_posted) )

-- Voucher Misc Distributions
UNION ALL SELECT vohead_vend_id AS vendid, vohead_id AS orderid, 3 AS itemid,
             vohead_number AS vouchernumber, '' AS ponumber, '' AS invoicenumber,
             'Misc' AS itemnumber, 'Miscellaneous Distribution' AS description,
             '' AS itemtype, '' AS iteminvuom, '' AS f_qty,
             vodist_amount AS cost, formatMoney(vodist_amount) AS f_cost,
             CASE WHEN(expcat_id IS NOT NULL) THEN (expcat_code||' - ' || expcat_descrip)
                  ELSE formatGLAccountLong(vodist_accnt_id)
             END AS account
FROM vohead, vodist LEFT OUTER JOIN expcat ON (vodist_expcat_id=expcat_id)
WHERE ( (vodist_vohead_id=vohead_id)
 AND (vodist_poitem_id=-1)
 AND (NOT vohead_posted) )

-- Voucher PO Line Distributions
UNION ALL
SELECT vohead.vohead_vend_id AS vendid, vohead.vohead_id AS orderid, 4 AS itemid,
       vohead.vohead_number AS vouchernumber, '' AS ponumber, '' AS invoicenumber,
       poitem.poitem_vend_item_descrip AS itemnumber, '' AS itemtype,
       poitem.poitem_vend_item_descrip, poitem.poitem_vend_uom, formatqty(vodist.vodist_qty) AS f_qty,
       vodist.vodist_amount AS cost, formatmoney(vodist.vodist_amount) AS f_cost,
CASE
WHEN accnt.accnt_id IS NULL THEN 'Not Assigned'::text
ELSE formatglaccountlong(accnt.accnt_id)
END AS account
FROM vohead, vodist, poitem, expcat LEFT JOIN accnt ON expcat.expcat_liability_accnt_id = accnt.accnt_id
WHERE vodist.vodist_vohead_id = vohead.vohead_id
  AND vodist.vodist_poitem_id <> -1
  AND vodist.vodist_poitem_id = poitem.poitem_id
  AND (poitem.poitem_itemsite_id = -1 OR poitem.poitem_itemsite_id IS NULL)
  AND expcat_id = poitem_expcat_id
  AND NOT vohead.vohead_posted

ORDER BY vouchernumber, itemid;

REVOKE ALL ON voucheringEditList FROM PUBLIC;
GRANT ALL ON voucheringEditList TO GROUP xtrole;
