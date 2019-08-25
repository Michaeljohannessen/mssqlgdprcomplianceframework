CREATE TABLE [dbo].[Table] (
    [TableID]   INT            IDENTITY (1, 1) NOT NULL,
    [Name]      NVARCHAR (255) NOT NULL,
    [Type]      NVARCHAR (255) NOT NULL,
    [SchemaID]  INT            NOT NULL,
    [IsDeleted] INT            CONSTRAINT [DF_Table_IsDeleted] DEFAULT ((0)) NOT NULL,
    [Modified]  DATETIME       CONSTRAINT [DF_Table_Modified] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Table] PRIMARY KEY CLUSTERED ([TableID] ASC),
    CONSTRAINT [UQ_Table_Name_SchemaID] UNIQUE NONCLUSTERED ([Name] ASC, [SchemaID] ASC)
);

