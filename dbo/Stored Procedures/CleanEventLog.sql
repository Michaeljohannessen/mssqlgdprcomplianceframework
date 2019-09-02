CREATE PROCEDURE dbo.CleanEventLog
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

BEGIN TRY

    DECLARE @EventLogRetentionPeriod INT;

    SELECT TOP (1)
           @EventLogRetentionPeriod = CAST([Value] AS INT)
    FROM [dbo].[Setting]
    WHERE [Name] = 'EventLogRetentionPeriod';

    DELETE FROM dbo.EventLog
    WHERE Started < DATEADD(DAY, @EventLogRetentionPeriod * -1, GETDATE());

    /* end logging */
    UPDATE [dbo].[EventLog]
    SET [Finished] = GETDATE(),
        [Status] = 'Finished'
    WHERE EventLogID = @CurrentEventLogID;
END TRY
BEGIN CATCH

    /* end logging with error */
    UPDATE [dbo].[EventLog]
    SET [Description] = [Description] + ' - The following error was raised during the execution: ' + ERROR_MESSAGE(),
        [Finished] = GETDATE(),
        [Status] = 'Finished with error'
    WHERE EventLogID = @CurrentEventLogID;
END CATCH;