CREATE TABLE [dbo].[CRM_CardPolicy_H] (
    [PolicyId]   INT              NOT NULL,
    [CardTypeId] INT              NULL,
    [MinPoint]   INT              NULL,
    [Discount]   FLOAT (53)       NULL,
    [IsVip]      BIT              NULL,
    [PolicyName] NVARCHAR (255)   NULL,
    [FromDate]   DATE             NULL,
    [ToDate]     DATE             NULL,
    [SaveDate]   DATETIME         NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_CardPolicy_H_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_CardPolicy_H_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

