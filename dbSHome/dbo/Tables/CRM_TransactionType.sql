CREATE TABLE [dbo].[CRM_TransactionType] (
    [TransTypeId]   INT              NULL,
    [TransTypeName] NVARCHAR (50)    NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_TransactionType_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_TransactionType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

