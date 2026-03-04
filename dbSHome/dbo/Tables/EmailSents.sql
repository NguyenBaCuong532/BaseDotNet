CREATE TABLE [dbo].[EmailSents] (
    [id]          UNIQUEIDENTIFIER CONSTRAINT [DF_EmailSents_id] DEFAULT (newid()) NOT NULL,
    [mailto]      NVARCHAR (255)   NULL,
    [cc]          NVARCHAR (255)   NULL,
    [bcc]         NVARCHAR (255)   NULL,
    [sendBy]      NVARCHAR (200)   NULL,
    [subject]     NVARCHAR (200)   NULL,
    [contents]    NVARCHAR (MAX)   NULL,
    [bodyType]    NVARCHAR (20)    NULL,
    [attachs]     NVARCHAR (MAX)   NULL,
    [status]      INT              NULL,
    [send]        INT              NULL,
    [sendName]    NVARCHAR (50)    NULL,
    [sendDate]    DATETIME         NULL,
    [sendType]    SMALLINT         NULL,
    [custId]      NVARCHAR (100)   NULL,
    [isRead]      BIT              NULL,
    [readDt]      DATETIME         NULL,
    [createId]    NVARCHAR (250)   NULL,
    [createdDate] DATETIME         NULL,
    [clientId]    NVARCHAR (50)    NULL,
    [clientIp]    NVARCHAR (50)    NULL,
    [sourceId]    UNIQUEIDENTIFIER NULL,
    [remart]      NVARCHAR (250)   NULL,
    [saveDt]      DATETIME         NULL,
    [error_mess]  NVARCHAR (250)   NULL,
    [sourceKey]   NVARCHAR (20)    NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_EmailSents] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_EmailSents_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_EmailSents_sourceId]
    ON [dbo].[EmailSents]([sourceId] ASC);

