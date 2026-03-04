CREATE TABLE [dbo].[MigrationBaseline_Run] (
    [RunId]       INT            IDENTITY (1, 1) NOT NULL,
    [CreatedAt]   DATETIME2 (7)  DEFAULT (sysdatetime()) NOT NULL,
    [Description] NVARCHAR (500) NULL,
    PRIMARY KEY CLUSTERED ([RunId] ASC)
);

