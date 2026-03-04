CREATE TABLE [dbo].[UserConfig] (
    [id]          UNIQUEIDENTIFIER CONSTRAINT [DF_UserConfig_id] DEFAULT (newid()) NOT NULL,
    [userId]      UNIQUEIDENTIFIER NOT NULL,
    [categoryIds] NVARCHAR (MAX)   NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_UserConfig_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

