CREATE TABLE [dbo].[user_rocketchat_vistor] (
    [id]            NVARCHAR (50)    NOT NULL,
    [user_id]       NVARCHAR (50)    NULL,
    [department_id] NVARCHAR (50)    NULL,
    [token]         NVARCHAR (256)   NULL,
    [created_at]    DATETIME         CONSTRAINT [DF_user_rocketchat_vistor_created_at] DEFAULT (getdate()) NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_user_rocketchat_vistor_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_user_rocketchat_vistor] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_user_rocketchat_vistor_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

