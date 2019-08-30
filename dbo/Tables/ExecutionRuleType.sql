CREATE TABLE [dbo].[ExecutionRuleType] (
    [ExecutionRuleTypeID] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (255) NOT NULL,
    [Description]         NVARCHAR (255) NULL,
    [Modified]            DATETIME       CONSTRAINT [DF_ExecutionRuleType_Modified] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExecutionRuleType] PRIMARY KEY CLUSTERED ([ExecutionRuleTypeID] ASC),
    CONSTRAINT [UQ_ExecutionRuleType_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

