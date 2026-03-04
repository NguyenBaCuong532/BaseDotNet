CREATE TABLE [dbo].[user_role] (
    [user_id]    NVARCHAR (50)    NOT NULL,
    [role_id]    UNIQUEIDENTIFIER NOT NULL,
    [created_dt] DATETIME2 (7)    CONSTRAINT [DF_user_role_created_dt] DEFAULT (sysdatetime()) NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_user_role_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_user_role] PRIMARY KEY CLUSTERED ([user_id] ASC, [role_id] ASC),
    CONSTRAINT [FK_user_role_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

