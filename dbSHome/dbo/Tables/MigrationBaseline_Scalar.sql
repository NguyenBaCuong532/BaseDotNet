CREATE TABLE [dbo].[MigrationBaseline_Scalar] (
    [RunId]       INT            NOT NULL,
    [ObjectName]  NVARCHAR (128) NOT NULL,
    [InputParams] NVARCHAR (500) NULL,
    [ResultValue] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([RunId] ASC, [ObjectName] ASC),
    FOREIGN KEY ([RunId]) REFERENCES [dbo].[MigrationBaseline_Run] ([RunId])
);

