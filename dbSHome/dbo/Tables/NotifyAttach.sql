CREATE TABLE [dbo].[NotifyAttach] (
    [notiId]         BIGINT           NOT NULL,
    [attach_name]    NVARCHAR (200)   NULL,
    [attach_url]     NVARCHAR (440)   NOT NULL,
    [attach_sysdate] DATETIME         CONSTRAINT [DF_NotifyAttach_attach_SysDate] DEFAULT (getdate()) NOT NULL,
    [attach_type]    NVARCHAR (20)    NULL,
    [n_id]           UNIQUEIDENTIFIER NULL,
    [created_dt]     DATETIME         NULL,
    [attach_size]    INT              NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_NotifyAttach_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_NotifyAttach] PRIMARY KEY CLUSTERED ([notiId] ASC, [attach_url] ASC),
    CONSTRAINT [FK_NotifyAttach_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_NotifyAttach_n_id]
    ON [dbo].[NotifyAttach]([n_id] ASC);

