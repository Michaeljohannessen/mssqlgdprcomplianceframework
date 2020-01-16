# Microsoft SQL Server GDPR Compliance Framework
Welcome to **Microsoft SQL Server GDPR Compliance Framework**. The purpose of the framework is pretty simple. During my career i have seen multiple companies with a need for a small execution framework to let users create what i call **ExecutionRules** - this rule could be clearing of a table and that is what brought up the idea of the framework. 

## How we install it
The project supports **Microsoft SQL Server 2016 >** and you install it by cloning the repository to your local machine and open it using Visual Studio 2017 > with support for database projects.

```sql
/* Create Compliance Framework Database */
CREATE DATABASE [ComplianceFramework];
GO
```

Now we are ready to compare the project to the database and load the framework to the newly created database!

![VS Schema Compare](misc/VS%20Schema%20Compare.png)

When the framework is loaded to the database, we are ready to initiate it.

```sql
USE [ComplianceFramework];

/* Load Default Setup And Settings */
EXEC [dbo].[LoadDefaultSetupAndSettings];
GO

/* View Event Log */
SELECT [EventLogID],
       [Object],
       [Description],
       [Status],
       [Started],
       [Finished]
FROM [dbo].[ViewEventLogs]
ORDER BY [Started] DESC;

/* Verify Settings */
SELECT [SettingID],
       [Name],
       [Value],
       [Description],
       [Modified]
FROM [dbo].[ViewSettings];
```

Now we have initiated the settings for the framework and it is time to synchronize the setup of your SQL Server. Because we are iterating over all databases on the server, we need a user with permission to read from all the databases to proceed with this synchronize!

```sql
/* Synchronize Environment Metadata */
EXEC [dbo].[SynchronizeEnvironmentMetadata];
GO

/* View Event Log */
SELECT [EventLogID],
       [Object],
       [Description],
       [Status],
       [Started],
       [Finished]
FROM [dbo].[ViewEventLogs]
ORDER BY [Started] DESC;

/* Update Metadata to include Databases into Framerwork */
UPDATE [dbo].[Database]
SET [SynchronizeMetadata] = 1
WHERE [Name] = 'ComplianceFramework';

SELECT [DatabaseID],
       [Name],
       [SynchronizeMetadata],
       [IsDeleted],
       [Modified]
FROM [dbo].[Database];

/* Synchronize Environment Metadata after Updating Metadata */
EXEC [dbo].[SynchronizeEnvironmentMetadata];
GO

/* View Event Log */
SELECT [EventLogID],
       [Object],
       [Description],
       [Status],
       [Started],
       [Finished]
FROM [dbo].[ViewEventLogs]
ORDER BY [Started] DESC;

/* View Meta Data Setup */
SELECT [ColumnID],
       [ColumnName],
       [TableID],
       [TableName],
       [TableType],
       [SchemaID],
       [SchemaName],
       [DatabaseID],
       [DatabaseName]
FROM [dbo].[ViewEnvironmentMetadata];
```

Now we have synchronized metadata for databases you decided to be included in the framework. Now it is time to take a look at the actual Execution Rules.

```sql
/* Check Execution Rule Types */
SELECT [ExecutionRuleTypeID],
       [Name],
       [Description],
       [Modified]
FROM [ComplianceFramework].[dbo].[ExecutionRuleType];

/* Creating a "User Defined Query"- rule */
INSERT INTO [dbo].[ExecutionRule]
(
    [Name],
    [Definition],
    [TableID],
    [ExecutionRuleTypeID],
    [Enabled]
)
VALUES
(   N'Test User Defined Query', N'SELECT 1 AS TestQueryResult',
    (
        SELECT TOP (1)
               [TableID]
        FROM [dbo].[ViewEnvironmentMetadata]
        WHERE [TableName] = 'EventLog'
              AND [DatabaseName] = 'ComplianceFramework'
    ),
    (
        SELECT [ExecutionRuleTypeID]
        FROM [dbo].[ExecutionRuleType]
        WHERE [Name] = 'User Defined Query'
    ), 1);

/* Creating a "Where Clause"- rule */
INSERT INTO [dbo].[ExecutionRule]
(
    [Name],
    [Definition],
    [TableID],
    [ExecutionRuleTypeID],
    [Enabled]
)
VALUES
(   N'Test Where Clause', N'Finished < DATEADD(DAY, -365, GETDATE())',
    (
        SELECT TOP (1)
               [TableID]
        FROM [dbo].[ViewEnvironmentMetadata]
        WHERE [TableName] = 'EventLog'
              AND [DatabaseName] = 'ComplianceFramework'
    ),
    (
        SELECT [ExecutionRuleTypeID]
        FROM [dbo].[ExecutionRuleType]
        WHERE [Name] = 'Where Clause'
    ), 1);

/* Validating the Insertion of the two Rules we just created */
SELECT [ExecutionRuleID],
       [Name],
       [Definition],
       [Table],
       [ExecutionRuleType],
       [ExecutionRuleTypeDescription],
       [Enabled],
       [Modified]
FROM [dbo].[ViewExecutionRules];
```

Now we can try to execute the rules we created and validate with the EventLog.

```sql
/* Initiat Execute of all ExecutionRules */
EXEC [dbo].[ExecuteAllExecutionRules];

/* Validate Event Log */
SELECT [EventLogID],
       [Object],
       [Description],
       [Status],
       [Started],
       [Finished]
FROM [dbo].[ViewEventLogs]
ORDER BY [Started] DESC;
```

Following the settings you can Clean the Event Log with the following execution.

```sql
/* Initiat Clean Event Log */
EXEC [dbo].[CleanEventLog];
```

### Stored Procedures
Following Stored Procedures is available:
 - `CleanEventLog` - Procedure is cleaning up the EventLog according to the settings set in the Setting-table.
 - `ExecuteAllExecutionRules` - Primary procedure to use in the framework. Iterates over all Execution Rules and execute them using `ExecuteSpecificExecutionRule`.
 - `ExecuteSpecificExecutionRule` - Holds the business logic of the execution of an execution rule. Take an input Execution Rule ID.
 - `LoadDefaultSetupAndSettings` - Loads the default setup and settings. Procedure is used initially or if you wants to reset to default setup.
 - `SynchronizeEnvironmentMetadata` - Synchronize meta data about the environment including databases, schemas, tables and columns.

### Views
Following Views is available:
 - `ViewEnvironmentMetadata` - ViewEnvironmentMetadata
 - `ViewEventLogs` - ViewEventLogs
 - `ViewExecutionRules` - Change configuration in.
 - `ViewSettings` - Change configuration in.

## Setup Daily Execution Job
Create a Job in SQL Server Job Agent and schedule is to run as often as you like. The step should include execution of the following procedure: 

```sql
EXEC [dbo].[ExecuteAllExecutionRules]
```

## What's Next?
Through my career in the it-industry I have meet companies with a need for a small execution framework to let users create what i call **ExecutionRules**.

The project is quite small in it's current state, but if you want to contribute to the solution or have any request or ideas for improvements, feel free to contact me at mjo@pro-solution.dk or visit our homepage http://pro-solution.dk. 

Currently we haven't developed any frontend to manipulate the setup, but if you like to contribute or want to build a frontend in Corporation, dont hesitate to take contact to us! 