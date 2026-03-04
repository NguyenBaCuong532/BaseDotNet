CREATE TABLE [dbo].[NotifyTo] (
    [id]         UNIQUEIDENTIFIER CONSTRAINT [DF_NotifyTo_id] DEFAULT (newid()) NOT NULL,
    [sourceId]   UNIQUEIDENTIFIER NOT NULL,
    [to_level]   INT              NULL,
    [to_groups]  NVARCHAR (MAX)   NULL,
    [createId]   NVARCHAR (100)   NULL,
    [createDt]   DATETIME         CONSTRAINT [DF_NotifyTo_createDt] DEFAULT (getdate()) NULL,
    [to_type]    INT              NULL,
    [to_row]     INT              NULL,
    [to_count]   INT              NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_NotifyTo] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_NotifyTo_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_NotifyTo_sourceId]
    ON [dbo].[NotifyTo]([sourceId] ASC);

