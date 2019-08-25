CREATE VIEW dbo.OverviewEnvironmentMetadata
AS
SELECT col.ColumnID,
       col.Name AS ColumnName,
       tab.TableID,
       tab.Name AS TableName,
       tab.Type,
       sch.SchemaID,
       sch.Name AS SchemaName,
       dat.DatabaseID,
       dat.Name AS DatabaseName
FROM dbo.[Column] col
    LEFT JOIN dbo.[Table] tab
        ON tab.TableID = col.TableID
    LEFT JOIN dbo.[Schema] sch
        ON sch.SchemaID = tab.SchemaID
    LEFT JOIN dbo.[Database] dat
        ON dat.DatabaseID = sch.DatabaseID;