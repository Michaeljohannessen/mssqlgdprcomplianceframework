CREATE TABLE [dbo].[EventLog] (
    [EventLogID]  INT            IDENTITY (1, 1) NOT NULL,
    [Object]      NVARCHAR (255) NOT NULL,
    [Description] NVARCHAR (255) NOT NULL,
    [RuleID]      INT            NULL,
    [Started]     DATETIME       CONSTRAINT [DF_EventLog_Started] DEFAULT (getdate()) NOT NULL,
    [Finished]    DATETIME       NULL,
    [Status]      NVARCHAR (255) NULL,
    CONSTRAINT [PK_EventLog] PRIMARY KEY CLUSTERED ([EventLogID] ASC)
);

