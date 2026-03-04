CREATE TABLE [dbo].[MAS_Feedbacks] (
    [FeedbackId]     BIGINT           IDENTITY (1, 1) NOT NULL,
    [regUserId]      BIGINT           NULL,
    [userId]         NVARCHAR (100)   NULL,
    [FeedbackTypeId] INT              NULL,
    [Title]          NVARCHAR (100)   NULL,
    [Comment]        NVARCHAR (MAX)   NOT NULL,
    [InputDate]      DATETIME         NULL,
    [ClientId]       NVARCHAR (50)    NULL,
    [AppId]          INT              NULL,
    [ApartmentId]    INT              NULL,
    [Status]         INT              NULL,
    [Oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Feedbacks_Oid] DEFAULT (newid()) NOT NULL,
    [AttachOid]      UNIQUEIDENTIFIER NULL,
    [viewed_by]      UNIQUEIDENTIFIER NULL,
    [viewed_at]      DATETIME         NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    [apartOid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Feedbacks] PRIMARY KEY CLUSTERED ([Oid] ASC),
    CONSTRAINT [FK_MAS_Feedbacks_apartOid] FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments] ([oid]),
    CONSTRAINT [FK_MAS_Feedbacks_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

