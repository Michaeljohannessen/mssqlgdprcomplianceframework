CREATE TABLE [dbo].[ExecutionRule] (
    [ExecutionRuleID]         INT            IDENTITY (1, 1) NOT NULL,
    [Name]                    NVARCHAR (255) NOT NULL,
    [Definition]              NVARCHAR (MAX) NULL,
    [ExecutionRuleTypeID]     INT            NOT NULL,
    [Enabled]                 INT            CONSTRAINT [DF_ExecutionRule_Enabled] DEFAULT ((0)) NOT NULL,
    [RequiredExecutionRuleID] INT            NULL,
    [Modified]                DATETIME       CONSTRAINT [DF_ExecutionRule_Modified] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExecutionRule] PRIMARY KEY CLUSTERED ([ExecutionRuleID] ASC),
    CONSTRAINT [UQ_ExecutionRule_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);



