CREATE TABLE [dbo].[Column] (
    [ColumnID]  INT            IDENTITY (1, 1) NOT NULL,
    [Name]      NVARCHAR (255) NOT NULL,
    [TableID]   INT            NOT NULL,
    [IsDeleted] INT            CONSTRAINT [DF_Column_IsDeleted] DEFAULT ((0)) NOT NULL,
    [Modified]  DATETIME       CONSTRAINT [DF_Column_Modified] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Column] PRIMARY KEY CLUSTERED ([ColumnID] ASC),
    CONSTRAINT [UQ_Column_Name_TableID] UNIQUE NONCLUSTERED ([Name] ASC, [TableID] ASC)
);

