UPDATE priv set priv_name='ViewPersonalToDoItems' where priv_name='ViewPersonalTodoList';
UPDATE priv set priv_name='ViewAllToDoItems' where priv_name='ViewOtherTodoLists';
UPDATE priv set priv_name='MaintainPersonalToDoItems' where priv_name='MaintainPersonalTodoList';
UPDATE priv set priv_name='MaintainAllToDoItems' where priv_name='MaintainOtherTodoLists';
UPDATE priv set priv_name='ReassignToDoItems' where priv_name='ReassignTodoListItem';

UPDATE priv set priv_descrip='Can View ToDoItems when Owner or Assigned' where priv_name='ViewPersonalToDoItems';
UPDATE priv set priv_descrip='Can View all ToDoItems' where priv_name='ViewAllToDoItems';
UPDATE priv set priv_descrip='Can Add/Edit/Delete ToDoItems when Owner or Assigned' where priv_name='MaintainPersonalToDoItems';
UPDATE priv set priv_descrip='Can Add/Edit/Delete all ToDoItems' where priv_name='MaintainAllToDoItems';
UPDATE priv set priv_descrip='Can Reassign ToDoItems to other people' where priv_name='ReassignToDoItems';

DELETE FROM priv WHERE priv_name='OverrideTodoListItemData';

UPDATE priv set priv_name='ViewAllContacts', priv_descrip='Can View all Contacts' where priv_name='ViewContacts';
UPDATE priv set priv_name='MaintainAllContacts', priv_descrip='Can Add/Edit/Delete all Contacts' where priv_name='MaintainContacts';
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'ViewPersonalContacts', 'Can View Contacts when Owner or Assigned');
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'MaintainPersonalContacts', 'Can Add/Edit/Delete Contacts when Owner or Assigned');

UPDATE priv set priv_name='ViewAllCRMAccounts', priv_descrip='Can View all CRM Accounts' where priv_name='ViewCRMAccounts';
UPDATE priv set priv_name='MaintainAllCRMAccounts', priv_descrip='Can Add/Edit/Delete all CRM Accounts' where priv_name='MaintainCRMAccounts';
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'ViewPersonalCRMAccounts', 'Can View CRM Accounts when Owner or Assigned');
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'MaintainPersonalCRMAccounts', 'Can Add/Edit/Delete CRM Accounts when Owner or Assigned');

UPDATE priv set priv_name='ViewAllOpportunities', priv_descrip='Can View all Opportunities' where priv_name='ViewOpportunities';
UPDATE priv set priv_name='MaintainAllOpportunities', priv_descrip='Can Add/Edit/Delete all Opportunities' where priv_name='MaintainOpportunities';
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'ViewPersonalOpportunities', 'Can View Opportunities when Owner or Assigned');
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'MaintainPersonalOpportunities', 'Can Add/Edit/Delete Opportunities when Owner or Assigned');

UPDATE priv set priv_name='ViewAllIncidents', priv_descrip='Can View all Incidents' where priv_name='ViewIncidents';
UPDATE priv set priv_name='MaintainAllIncidents', priv_descrip='Can Add/Edit/Delete all Incidents' where priv_name='MaintainIncidents';
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'ViewPersonalIncidents', 'Can View Incidents when Owner or Assigned');
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'MaintainPersonalIncidents', 'Can Add/Edit/Delete Incidents when Owner or Assigned');

UPDATE priv set priv_name='ViewAllIncidentHistory', priv_descrip='Can View all Incident History' where priv_name='ViewIncidentHistory';
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'ViewPersonalIncidentHistory', 'Can View Incident History when Owner or Assigned');

UPDATE priv set priv_name='CloseAllIncidents', priv_descrip='Can Close all Incidents after confirming that it has been satisfactorily resolved' where priv_name='CloseIncident';
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'ClosePersonalIncidents', 'Can Incidents when Owner or Assigned after confirming that it has been resolved');

DELETE FROM priv WHERE priv_name='AddIncidents';
DELETE FROM priv WHERE priv_name='EditOwnIncidentLog';

UPDATE priv set priv_name='ViewAllProjects', priv_descrip='Can View all Projects' where priv_name='ViewProjects';
UPDATE priv set priv_name='MaintainAllProjects', priv_descrip='Can Add/Edit/Delete all Projects' where priv_name='MaintainProjects';
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'ViewPersonalProjects', 'Can View Projects when Owner or Assigned');
INSERT INTO priv (priv_module, priv_name, priv_descrip) VALUES ('CRM', 'MaintainPersonalProjects', 'Can Add/Edit/Delete Projects when Owner or Assigned');

ALTER TABLE priv ADD COLUMN priv_seq INTEGER;
UPDATE priv set priv_seq = 0 WHERE priv_name ~ 'MaintainAll';
UPDATE priv set priv_seq = 1 WHERE priv_name ~ 'ViewAll';
UPDATE priv set priv_seq = 2 WHERE priv_name ~ 'MaintainPersonal';
UPDATE priv set priv_seq = 4 WHERE priv_name ~ 'ViewPersonal';
