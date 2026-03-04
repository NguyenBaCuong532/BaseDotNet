CREATE TABLE [dbo].[ELE_CardRole] (
    [Id]         INT              IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RoleName]   NVARCHAR (50)    NOT NULL,
    [created_at] DATETIME         CONSTRAINT [DF_ELE_CardRole_created_at] DEFAULT (getdate()) NULL,
    [created_by] NVARCHAR (255)   NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_ELE_CardRole_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ELE_CardRole] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ELE_CardRole_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

