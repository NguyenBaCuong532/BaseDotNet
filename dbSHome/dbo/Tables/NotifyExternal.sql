CREATE TABLE [dbo].[NotifyExternal] (
    [external_sub]  NVARCHAR (50)    NOT NULL,
    [external_name] NVARCHAR (200)   NOT NULL,
    [created_dt]    DATETIME         NULL,
    [created_by]    NVARCHAR (100)   NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_NotifyExternal_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_NotifyExternal] PRIMARY KEY CLUSTERED ([external_sub] ASC),
    CONSTRAINT [FK_NotifyExternal_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

