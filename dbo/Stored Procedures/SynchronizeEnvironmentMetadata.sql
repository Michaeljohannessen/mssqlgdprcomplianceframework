CREATE PROCEDURE dbo.SynchronizeEnvironmentMetadata
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

    /* declaring objects and variables */
    DECLARE @TableStoreAllMetadata TABLE
    (
        ColumnName NVARCHAR(255),
        TableName NVARCHAR(255),
        TableType NVARCHAR(255),
        SchemaName NVARCHAR(255),
        DatabaseName NVARCHAR(255)
    );

    DECLARE @QueryGetAllMetadata NVARCHAR(MAX);

    /* synchronizing metadata about databases from master.sys.databases */
    MERGE dbo.[Database] tgt
    USING master.sys.databases src
    ON (src.[name] = tgt.[Name])
    WHEN MATCHED AND tgt.IsDeleted != 0 THEN
        UPDATE SET tgt.Modified = GETDATE(),
                   tgt.IsDeleted = 0
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            [Name]
        )
        VALUES
        (src.[name])
    WHEN NOT MATCHED BY SOURCE AND tgt.IsDeleted != 1 THEN
        UPDATE SET tgt.IsDeleted = 1,
                   tgt.Modified = GETDATE();

    /* dynamically get metadata from all databases on instance */
    SELECT @QueryGetAllMetadata
        =
    (
        SELECT 'UNION ALL 
SELECT Col.COLUMN_NAME COLLATE DATABASE_DEFAULT AS [ColumnName],
       Col.TABLE_NAME COLLATE DATABASE_DEFAULT AS [TableName],
	   Tab.TABLE_TYPE COLLATE DATABASE_DEFAULT AS [TableType],
       Col.TABLE_SCHEMA COLLATE DATABASE_DEFAULT AS [SchemaName],
       Col.TABLE_CATALOG COLLATE DATABASE_DEFAULT AS [DatabaseName]
FROM ' +    QUOTENAME(name) + '.INFORMATION_SCHEMA.COLUMNS Col
    LEFT JOIN ' + QUOTENAME(name)
               + '.INFORMATION_SCHEMA.TABLES Tab
        ON Tab.TABLE_CATALOG = Col.TABLE_CATALOG
           AND Tab.TABLE_SCHEMA = Col.TABLE_SCHEMA
           AND Tab.TABLE_NAME = Col.TABLE_NAME
'
        FROM sys.databases
        WHERE [name] IN
    (
        SELECT [Name]
        FROM dbo.[Database]
        WHERE SynchronizeMetadata = 1
              AND IsDeleted = 0
    )
        ORDER BY [name]
        FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)');

    /* removing leading UNION ALL */
    SET @QueryGetAllMetadata = STUFF(@QueryGetAllMetadata, 1, 12, '');

    /* insert metadata into a temp table variable */
    INSERT @TableStoreAllMetadata
    EXECUTE (@QueryGetAllMetadata);

    /* synchronizing metadata about schemas */
    WITH [Schemas]
    AS (SELECT DISTINCT
               db.DatabaseID,
               metadata.SchemaName
        FROM @TableStoreAllMetadata metadata
            LEFT JOIN dbo.[Database] db
                ON db.[Name] = metadata.DatabaseName)
    MERGE dbo.[Schema] tgt
    USING [Schemas] src
    ON (
           src.[DatabaseID] = tgt.[DatabaseID]
           AND src.SchemaName = tgt.[Name]
       )
    WHEN MATCHED AND tgt.IsDeleted != 0 THEN
        UPDATE SET tgt.Modified = GETDATE(),
                   tgt.IsDeleted = 0
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            [Name],
            [DatabaseID]
        )
        VALUES
        (src.SchemaName, src.[DatabaseID])
    WHEN NOT MATCHED BY SOURCE AND tgt.IsDeleted != 1 THEN
        UPDATE SET tgt.IsDeleted = 1,
                   tgt.Modified = GETDATE();

    /* synchronizing metadata about tables */
    WITH [Tables]
    AS (SELECT DISTINCT
               metadata.TableName,
               metadata.TableType,
               sch.SchemaID
        FROM @TableStoreAllMetadata metadata
            LEFT JOIN dbo.[Database] db
                ON db.[Name] = metadata.DatabaseName
            LEFT JOIN dbo.[Schema] sch
                ON sch.[Name] = metadata.SchemaName
                   AND sch.DatabaseID = db.DatabaseID)
    MERGE dbo.[Table] tgt
    USING [Tables] src
    ON (
           src.[SchemaID] = tgt.[SchemaID]
           AND src.TableName = tgt.[Name]
       )
    WHEN MATCHED AND tgt.IsDeleted != 0 THEN
        UPDATE SET tgt.Modified = GETDATE(),
                   tgt.IsDeleted = 0
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            [Name],
            [Type],
            [SchemaID]
        )
        VALUES
        (src.TableName, src.TableType, src.[SchemaID])
    WHEN NOT MATCHED BY SOURCE AND tgt.IsDeleted != 1 THEN
        UPDATE SET tgt.IsDeleted = 1,
                   tgt.Modified = GETDATE();

    /* synchronizing metadata about columns */
    WITH [Columns]
    AS (SELECT DISTINCT
               metadata.ColumnName,
               tab.TableID
        FROM @TableStoreAllMetadata metadata
            LEFT JOIN dbo.[Database] db
                ON db.[Name] = metadata.DatabaseName
            LEFT JOIN dbo.[Schema] sch
                ON sch.[Name] = metadata.SchemaName
                   AND sch.DatabaseID = db.DatabaseID
            LEFT JOIN dbo.[Table] tab
                ON tab.[Name] = metadata.TableName
                   AND tab.SchemaID = sch.SchemaID)
    MERGE dbo.[Column] tgt
    USING [Columns] src
    ON (
           src.[TableID] = tgt.[TableID]
           AND src.ColumnName = tgt.[Name]
       )
    WHEN MATCHED AND tgt.IsDeleted != 0 THEN
        UPDATE SET tgt.Modified = GETDATE(),
                   tgt.IsDeleted = 0
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            [Name],
            [TableID]
        )
        VALUES
        (src.ColumnName, src.[TableID])
    WHEN NOT MATCHED BY SOURCE AND tgt.IsDeleted != 1 THEN
        UPDATE SET tgt.IsDeleted = 1,
                   tgt.Modified = GETDATE();

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