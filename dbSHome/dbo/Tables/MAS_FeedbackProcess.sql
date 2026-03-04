CREATE TABLE [dbo].[MAS_FeedbackProcess] (
    [ProcessId]  INT              IDENTITY (1, 1) NOT NULL,
    [FeedbackId] INT              NOT NULL,
    [Comment]    NVARCHAR (MAX)   NULL,
    [ProcessDt]  DATETIME         NULL,
    [userId]     NVARCHAR (100)   NULL,
    [Status]     INT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_FeedbackProcess_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_FeedbackProcess] PRIMARY KEY CLUSTERED ([ProcessId] ASC),
    CONSTRAINT [FK_MAS_FeedbackProcess_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

