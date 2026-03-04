CREATE TABLE [dbo].[security_policy] (
    [Oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_security_policy_Oid] DEFAULT (newid()) NOT NULL,
    [code]       NVARCHAR (50)    NULL,
    [name]       NVARCHAR (100)   NULL,
    [content]    NVARCHAR (MAX)   NULL,
    [created]    DATETIME         NULL,
    [created_by] NVARCHAR (50)    NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_security_policy] PRIMARY KEY CLUSTERED ([Oid] ASC),
    CONSTRAINT [FK_security_policy_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

