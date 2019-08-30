﻿CREATE PROCEDURE dbo.ExecuteAllExecutionRules
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
    (OBJECT_NAME(@@PROCID), 'Execute Stored Procedure', GETDATE(), 'Running');

    SET @CurrentEventLogID = SCOPE_IDENTITY();

    BEGIN TRY

        DECLARE @CurrentExecutionRuleID INT;

        -- declaring cursor for execution rules
        DECLARE ExecutionRulesCursor CURSOR FOR
        SELECT ExecutionRuleID
        FROM [dbo].[ExecutionRule]
        WHERE [Enabled] = 1;

        -- iterate over elements in cursor
        OPEN ExecutionRulesCursor;
        FETCH NEXT FROM ExecutionRulesCursor
        INTO @CurrentExecutionRuleID;

        WHILE @@FETCH_STATUS = 0
        BEGIN

            -- call ExecuteSpecificExecutionRule for each active execution rule
            EXEC [dbo].[ExecuteSpecificExecutionRule] @ExecutionRuleID = @CurrentExecutionRuleID;

            FETCH NEXT FROM ExecutionRulesCursor
            INTO @CurrentExecutionRuleID;
        END;

        -- cleanup cursor
        CLOSE ExecutionRulesCursor;
        DEALLOCATE ExecutionRulesCursor;

        /* end logging */
        UPDATE [dbo].[EventLog]
        SET [Finished] = GETDATE(),
            [Status] = 'Finished'
        WHERE EventLogID = @CurrentEventLogID;
    END TRY
    BEGIN CATCH

        /* end logging with error */
        UPDATE [dbo].[EventLog]
        SET [Description] = 'The following error was raised during the execution: ' + ERROR_MESSAGE(),
            [Finished] = GETDATE(),
            [Status] = 'Finished with error'
        WHERE EventLogID = @CurrentEventLogID;
    END CATCH;

END;