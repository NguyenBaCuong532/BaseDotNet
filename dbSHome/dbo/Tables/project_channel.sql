CREATE TABLE [dbo].[project_channel] (
    [id]           UNIQUEIDENTIFIER CONSTRAINT [DF_project_channel_id] DEFAULT (newid()) NOT NULL,
    [project_code] NVARCHAR (10)    NULL,
    [channel_id]   NCHAR (10)       NULL,
    [is_community] BIT              NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_project_channel] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_project_channel_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

