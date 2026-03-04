CREATE TABLE [dbo].[WAL_BkTransactionPay] (
    [BkTransactionId]   NVARCHAR (50)    NOT NULL,
    [BankTransactionID] NVARCHAR (50)    NOT NULL,
    [BankAmount]        DECIMAL (28)     NOT NULL,
    [BankTransactionDt] DATETIME         NULL,
    [BankDescription]   NVARCHAR (150)   NULL,
    [BankName]          NVARCHAR (50)    NULL,
    [oid]               UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_BkTransactionPay_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]        UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_BkTransactionPay] PRIMARY KEY CLUSTERED ([BankTransactionID] ASC),
    CONSTRAINT [FK_WAL_BkTransactionPay_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

