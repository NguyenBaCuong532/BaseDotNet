CREATE TABLE [dbo].[transaction_payment_draft] (
    [Oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_transaction_payment_draft_Oid] DEFAULT (newid()) NOT NULL,
    [sourceOid]      UNIQUEIDENTIFIER NULL,
    [transNo]        NVARCHAR (50)    NULL,
    [amount]         DECIMAL (18)     NULL,
    [brct]           INT              NULL,
    [virtualAcc]     NVARCHAR (50)    NULL,
    [virtualPartNum] NVARCHAR (15)    NULL,
    [displayName]    NVARCHAR (150)   NULL,
    [actualAccount]  NVARCHAR (50)    NULL,
    [type]           NVARCHAR (20)    NOT NULL,
    [customerName]   NVARCHAR (50)    NULL,
    [metadata]       NVARCHAR (250)   NULL,
    [source]         NVARCHAR (50)    CONSTRAINT [DF_transaction_payment_draft_source] DEFAULT (N'CMS') NULL,
    [created]        DATETIME         NULL,
    [created_by]     NVARCHAR (50)    NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_transaction_payment_draft_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CMS|APP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'transaction_payment_draft', @level2type = N'COLUMN', @level2name = N'source';

