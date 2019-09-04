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
        DECLARE @BuiltQuery NVARCHAR(MAX);

        /* declaring variables related to execution rule */
        DECLARE @ExecutionName NVARCHAR(255);
        DECLARE @ExecutionDefinition NVARCHAR(MAX);
        DECLARE @ExecutionRuleType NVARCHAR(255);
        DECLARE @DatabaseName NVARCHAR(255);
        DECLARE @SchemaName NVARCHAR(255);
        DECLARE @TableID INT;
        DECLARE @TableName NVARCHAR(255);

        /* getting definition of execution rule */
        SELECT @ExecutionName = ExecutionRule.Name,
               @ExecutionDefinition = ExecutionRule.Definition,
               @ExecutionRuleType = ExecutionRuleType.Name,
               @TableID = ExecutionRule.TableID
        FROM dbo.ExecutionRule ExecutionRule
            INNER JOIN dbo.ExecutionRuleType ExecutionRuleType
                ON ExecutionRuleType.ExecutionRuleTypeID = ExecutionRule.ExecutionRuleTypeID
        WHERE ExecutionRule.ExecutionRuleID = @ExecutionRuleID
              AND ExecutionRule.Enabled = 1;

        /* getting meta data information regarding selected execution rule */
        SELECT DISTINCT
               @TableName = TableName,
               @SchemaName = SchemaName,
               @DatabaseName = DatabaseName
        FROM dbo.ViewEnvironmentMetadata
        WHERE TableID = @TableID;

        /* build up query for type of user defined query */
        IF (@ExecutionRuleType = 'User Defined Query')
        BEGIN
            SET @BuiltQuery = N'USE [' + @DatabaseName + N']; ' + @ExecutionDefinition;
        END;

        /* build up query for type of where clause */
        IF (@ExecutionRuleType = 'Where Clause')
        BEGIN
            SET @ExecutionDefinition = TRIM(@ExecutionDefinition);

            /* if user did not put 'where' in front of the definition */
            IF (UPPER(SUBSTRING(@ExecutionDefinition, 1, 5)) != 'WHERE')
            BEGIN
                SET @ExecutionDefinition = N' WHERE ' + @ExecutionDefinition;
            END;

            SET @BuiltQuery
                = N'USE [' + @DatabaseName + N']; DELETE FROM [' + @SchemaName + N'].[' + @TableName + N'] '
                  + @ExecutionDefinition;
        END;

        /* executing the built query */
        EXEC (@BuiltQuery);

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