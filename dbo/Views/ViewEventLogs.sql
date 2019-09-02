CREATE VIEW [dbo].[ViewEventLogs]
AS
SELECT [EventLogID],
       [Object],
       [Description],
       [Status],
       [Started],
       [Finished]
FROM [dbo].[EventLog];