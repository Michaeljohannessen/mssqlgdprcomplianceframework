# Microsoft SQL Server GDPR Compliance Framework
Welcome to **Microsoft SQL Server GDPR Compliance Framework**. The purpose of the framework is pretty simple. During my career i have seen multiple companies with a need for a small execution framework to let users create what i call **ExecutionRules** - this rule could be clearing of a table and that is what brought up the idea of this framework. 

## How we install it
The project supports **Microsoft SQL Server 2016 >** and you install it by cloning the repository to your local machine and open it using Visual Studio 2017 > with support for database projects.
```sql
/* Create Compliance Framework Database */
CREATE DATABASE [ComplianceFramework];
GO
```
Now we are ready to compare the project to the database and load the framework to the newly created database!
![VS Schema Compare](misc/VS%20Schema%20Compare.png)