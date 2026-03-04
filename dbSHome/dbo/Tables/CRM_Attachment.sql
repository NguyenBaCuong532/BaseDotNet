CREATE TABLE [dbo].[CRM_Attachment] (
    [ObjectId]      VARCHAR (150)    NOT NULL,
    [AttachmentUrl] NVARCHAR (255)   NULL,
    [Type]          NVARCHAR (50)    NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Attachment_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_Attachment_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

