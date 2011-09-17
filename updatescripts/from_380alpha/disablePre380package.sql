/* the pre380 package works around bugs in the crmaccounts-details metasql
   statement by defining one of a higher grade. however, the version in
   the package can't know about some of the new columns in the crmacct
   table. therefore we need to disable or delete that package for 3.8.0's
   crmaccounts and crmaccountMergePickAccounts windows to work correctly.
*/
SELECT disablePackage(pkghead_id)
  FROM pkghead
 WHERE (pkghead_name='pre380');
