CREATE TABLE [dbo].[user_favorite_service] (
    [id]         UNIQUEIDENTIFIER CONSTRAINT [DF_user_favorite_service_id] DEFAULT (newid()) NOT NULL,
    [user_id]    UNIQUEIDENTIFIER NULL,
    [service_id] UNIQUEIDENTIFIER NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_user_favorite_service] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_user_favorite_service_service] FOREIGN KEY ([service_id]) REFERENCES [dbo].[service] ([id]),
    CONSTRAINT [FK_user_favorite_service_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

