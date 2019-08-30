CREATE PROCEDURE [dbo].[ExecuteSpecificExecutionRule] @ExecutionRuleID INT
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

		/* declaring variables */
		DECLARE @ExecutionName NVARCHAR(255);
		DECLARE @ExecutionDefinition NVARCHAR(MAX);

		SELECT ExecutionRule.ExecutionRuleID,
			   ExecutionRule.Name,
			   ExecutionRule.Definition,
			   ExecutionRuleType.Name AS [ExecutionType],
			   ExecutionRule.Enabled,
			   ExecutionRule.RequiredExecutionRuleID,
			   ExecutionRule.Modified
		FROM dbo.ExecutionRule ExecutionRule
			INNER JOIN dbo.ExecutionRuleType ExecutionRuleType
				ON ExecutionRuleType.ExecutionRuleTypeID = ExecutionRule.ExecutionRuleTypeID;

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