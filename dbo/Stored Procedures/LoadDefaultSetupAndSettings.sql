CREATE   PROCEDURE [dbo].[LoadDefaultSetupAndSettings]
AS

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

BEGIN TRY;

    /* default setting values */
    WITH DefaultSettings
    AS (SELECT N'EventLogRetentionPeriod' AS [Name],
               N'365' AS [Value],
               N'Event Log Retention Period in Days' AS [Description])

    /* set settings to default values using merge */
    MERGE dbo.Setting tgt
    USING DefaultSettings src
    ON (src.[Name] = tgt.[Name])
    WHEN MATCHED AND (
                         [tgt].[Value] != [src].[Value]
                         OR [tgt].[Description] != [src].[Description]
                     ) THEN
        UPDATE SET [tgt].[Value] = [src].[Value],
                   [tgt].[Description] = [src].[Description],
                   tgt.Modified = GETDATE()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            [Name],
            [Value],
            [Description]
        )
        VALUES
        (src.[Name], src.[Value], src.[Description])
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;

    /* default values in ExecutionType */
    WITH DefaultExecutionRuleTypes
    AS (SELECT N'Raw Query' AS [Name],
               N'Raw Query Defined by User' AS [Description])

    /* set settings to default values using merge */
    MERGE dbo.ExecutionRuleType tgt
    USING DefaultExecutionRuleTypes src
    ON (src.[Name] = tgt.[Name])
    WHEN MATCHED AND ([tgt].[Description] != [src].[Description]) THEN
        UPDATE SET [tgt].[Description] = [src].[Description],
                   tgt.Modified = GETDATE()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            [Name],
            [Description]
        )
        VALUES
        (src.[Name], src.[Description])
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;

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