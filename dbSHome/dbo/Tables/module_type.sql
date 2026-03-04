CREATE TABLE [dbo].[module_type] (
    [Oid]        UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [mod_cd]     NVARCHAR (16)    NOT NULL,
    [userType]   INT              NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_module_type_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

