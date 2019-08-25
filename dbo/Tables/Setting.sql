CREATE TABLE [dbo].[Setting] (
    [SettingID]   INT            IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (255) NOT NULL,
    [Value]       NVARCHAR (255) NOT NULL,
    [Description] NVARCHAR (255) NULL,
    [Modified]    DATETIME       CONSTRAINT [DF_Setting_Modified] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Setting] PRIMARY KEY CLUSTERED ([SettingID] ASC),
    CONSTRAINT [UQ_Setting_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

