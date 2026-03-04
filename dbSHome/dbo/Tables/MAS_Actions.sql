CREATE TABLE [dbo].[MAS_Actions] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [userId]     NVARCHAR (50)    NOT NULL,
    [projectCd]  NVARCHAR (50)    NULL,
    [url]        NVARCHAR (150)   NOT NULL,
    [api]        NVARCHAR (150)   NOT NULL,
    [action]     NVARCHAR (50)    NOT NULL,
    [data]       TEXT             NULL,
    [time]       NVARCHAR (50)    NOT NULL,
    [status]     INT              NOT NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Actions_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK__MAS_Acti__3214EC07AB271A25] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MAS_Actions_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

