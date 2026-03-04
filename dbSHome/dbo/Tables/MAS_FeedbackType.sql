CREATE TABLE [dbo].[MAS_FeedbackType] (
    [FeedbackTypeId]   INT              IDENTITY (1, 1) NOT NULL,
    [FeedbackTypeName] NVARCHAR (100)   NULL,
    [AppId]            INT              NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_FeedbackType_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_FeedbackType] PRIMARY KEY CLUSTERED ([FeedbackTypeId] ASC),
    CONSTRAINT [FK_MAS_FeedbackType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

