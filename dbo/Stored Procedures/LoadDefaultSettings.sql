CREATE PROCEDURE [dbo].[LoadDefaultSettings]
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

    TRUNCATE TABLE dbo.Setting;

    /* Merge into? TOOD */
    INSERT INTO dbo.Setting
    (
        Name,
        Value,
        Description,
        Modified
    )
    VALUES
    (   N'EventLogRetentionPeriod',           -- Name - nvarchar(255)
        N'365',                               -- Value - nvarchar(255)
        N'EventLog Retention Period in Days', -- Description - nvarchar(255)
        GETDATE()                             -- Modified - datetime
        );

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