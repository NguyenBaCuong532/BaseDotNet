CREATE TABLE [dbo].[role] (
    [id]          UNIQUEIDENTIFIER CONSTRAINT [DF_role_id] DEFAULT (newid()) NOT NULL,
    [name]        VARCHAR (100)    NOT NULL,
    [description] VARCHAR (255)    NULL,
    [created_dt]  DATETIME2 (7)    CONSTRAINT [DF__Roles__created_dt] DEFAULT (sysdatetime()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Roles_id] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_role_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_Roles_name] UNIQUE NONCLUSTERED ([name] ASC)
);

