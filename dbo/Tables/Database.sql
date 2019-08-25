CREATE TABLE [dbo].[Database] (
    [DatabaseID]          INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (255) NOT NULL,
    [SynchronizeMetadata] INT            CONSTRAINT [DF_Database_SynchronizeMetadata] DEFAULT ((0)) NOT NULL,
    [IsDeleted]           INT            CONSTRAINT [DF_Database_IsDeleted] DEFAULT ((0)) NOT NULL,
    [Modified]            DATETIME       CONSTRAINT [DF_Database_Modified] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Database] PRIMARY KEY CLUSTERED ([DatabaseID] ASC),
    CONSTRAINT [UQ_Database_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

