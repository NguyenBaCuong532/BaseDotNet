CREATE TABLE [dbo].[CRM_CardType] (
    [ImageUrl]   NVARCHAR (455)   NULL,
    [Ordering]   INT              NULL,
    [CardTypeId] INT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_CardType_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_CardType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

