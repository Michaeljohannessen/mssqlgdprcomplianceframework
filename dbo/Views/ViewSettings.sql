CREATE VIEW dbo.ViewSettings
AS
SELECT [SettingID],
       [Name],
       [Value],
       [Description],
       [Modified]
FROM [dbo].[Setting];