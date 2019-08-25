CREATE TABLE [dbo].[Schema] (
    [SchemaID]   INT            IDENTITY (1, 1) NOT NULL,
    [Name]       NVARCHAR (255) NOT NULL,
    [DatabaseID] INT            NOT NULL,
    [IsDeleted]  INT            CONSTRAINT [DF_Schema_IsDeleted] DEFAULT ((0)) NOT NULL,
    [Modified]   DATETIME       CONSTRAINT [DF_Schema_Modified] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Schema] PRIMARY KEY CLUSTERED ([SchemaID] ASC),
    CONSTRAINT [UQ_Schema_Name_DatabaseID] UNIQUE NONCLUSTERED ([Name] ASC, [DatabaseID] ASC)
);

