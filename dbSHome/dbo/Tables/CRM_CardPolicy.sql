CREATE TABLE [dbo].[CRM_CardPolicy] (
    [CardTypeId] INT              NULL,
    [MinPoint]   INT              NULL,
    [Discount]   FLOAT (53)       NULL,
    [IsVip]      BIT              CONSTRAINT [DF_CRM_Card_Policy_IsVip] DEFAULT ((0)) NULL,
    [PolicyName] NVARCHAR (255)   NULL,
    [FromDate]   DATE             NULL,
    [ToDate]     DATE             NULL,
    [PolicyId]   INT              IDENTITY (1, 1) NOT NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_CardPolicy_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_CardPolicy_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_CRM_CardPolicy_CardTypeId]
    ON [dbo].[CRM_CardPolicy]([CardTypeId] ASC);

