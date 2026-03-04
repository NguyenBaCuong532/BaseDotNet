CREATE TABLE [dbo].[NotifyJob] (
    [id]             NVARCHAR (100)   NOT NULL,
    [n_id]           UNIQUEIDENTIFIER NOT NULL,
    [userId]         NVARCHAR (100)   NULL,
    [custId]         NVARCHAR (100)   NULL,
    [content_notify] NVARCHAR (300)   NULL,
    [push_st]        INT              NULL,
    [createId]       NVARCHAR (100)   NULL,
    [createDt]       DATETIME         NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_NotifyJob_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_NotifyJob] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_NotifyJob_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

