CREATE PROCEDURE dbo.ExecuteSpecificExecutionRule @ExecutionRuleID INT
AS
BEGIN

    /* start logging */
    DECLARE @CurrentEventLogID INT;

    INSERT INTO [dbo].[EventLog]
    (
        [Object],
        [Description],
        [Started],
        [Status]
    )
    VALUES
    (OBJECT_NAME(@@PROCID), 'Execute Stored Procedure with @ExecutionRuleID = ' + CAST(@ExecutionRuleID AS NVARCHAR),
     GETDATE(), 'Running');

    SET @CurrentEventLogID = SCOPE_IDENTITY();

    BEGIN TRY

        /* declaring variables related to stored procedure */
        DECLARE @BuildQuery NVARCHAR(MAX);

        /* declaring variables related to execution rule */
        DECLARE @DatabaseID INT;
        DECLARE @DatabaseName NVARCHAR(255);
        DECLARE @ExecutionName NVARCHAR(255);
        DECLARE @ExecutionDefinition NVARCHAR(MAX);
        DECLARE @ExecutionRuleType NVARCHAR(255);

        /* getting definition of execution rule */
        SELECT @DatabaseID = ExecutionRule.DatabaseID,
               @ExecutionName = ExecutionRule.Name,
               @ExecutionDefinition = ExecutionRule.Definition,
               @ExecutionRuleType = ExecutionRuleType.Name
        FROM dbo.ExecutionRule ExecutionRule
            INNER JOIN dbo.ExecutionRuleType ExecutionRuleType
                ON ExecutionRuleType.ExecutionRuleTypeID = ExecutionRule.ExecutionRuleTypeID
        WHERE ExecutionRule.ExecutionRuleID = @ExecutionRuleID
              AND ExecutionRule.Enabled = 1;

        SELECT @DatabaseName = DatabaseName
        FROM dbo.ViewEnvironmentMetadata
        WHERE DatabaseID = @DatabaseID;

        /* build up query depending on type of execution rule */
        IF (@ExecutionRuleType = 'Raw SQL Query')
        BEGIN
            SET @BuildQuery = N'USE [' + @DatabaseName + N']; ' + @ExecutionDefinition;
        END;

        IF (@ExecutionRuleType = '222')
        BEGIN
            SET @BuildQuery = N'USE [' + @DatabaseName + N']; ' + @ExecutionDefinition;
        END;

        IF (@ExecutionRuleType = '333')
        BEGIN
            SET @BuildQuery = N'USE [' + @DatabaseName + N']; ' + @ExecutionDefinition;
        END;

        /* executing the cleanup procedure */
        EXEC (@BuildQuery);

        /* end logging */
        UPDATE [dbo].[EventLog]
        SET [Finished] = GETDATE(),
            [Status] = 'Finished'
        WHERE EventLogID = @CurrentEventLogID;
    END TRY
    BEGIN CATCH

        /* end logging with error */
        UPDATE [dbo].[EventLog]
        SET [Description] = [Description] + ' - The following error was raised during the execution: '
                            + ERROR_MESSAGE(),
            [Finished] = GETDATE(),
            [Status] = 'Finished with error'
        WHERE EventLogID = @CurrentEventLogID;
    END CATCH;

END;