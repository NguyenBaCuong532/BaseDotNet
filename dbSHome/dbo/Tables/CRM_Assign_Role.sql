CREATE TABLE [dbo].[CRM_Assign_Role] (
    [assignRole]     INT              NOT NULL,
    [assignRoleName] NVARCHAR (255)   NOT NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Assign_Role_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_Assign_Role_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

