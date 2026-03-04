CREATE TABLE [dbo].[MAS_FeedbackAttach] (
    [id]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [feedbackId]     BIGINT           NOT NULL,
    [processId]      BIGINT           NULL,
    [attachUrl]      NVARCHAR (455)   NOT NULL,
    [attachType]     NVARCHAR (50)    NULL,
    [attachFileName] NVARCHAR (200)   NULL,
    [createDt]       DATETIME         NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_FeedbackAttach_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_MAS_FeedbackAttach_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

