CREATE TABLE [dbo].[CRM_CardStatus] (
    [StatusName] NVARCHAR (50)    NULL,
    [StatusId]   INT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_CardStatus_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_CardStatus_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

