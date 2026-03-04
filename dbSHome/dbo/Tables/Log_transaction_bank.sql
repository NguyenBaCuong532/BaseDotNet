CREATE TABLE [dbo].[Log_transaction_bank] (
    [Type]          NVARCHAR (50)    NULL,
    [HeaderRequest] NVARCHAR (MAX)   NULL,
    [Request]       NVARCHAR (MAX)   NULL,
    [createDt]      DATETIME         CONSTRAINT [DF_Log_transaction_bank_createDt] DEFAULT (getdate()) NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_Log_transaction_bank_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_Log_transaction_bank_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

