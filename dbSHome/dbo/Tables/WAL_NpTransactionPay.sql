CREATE TABLE [dbo].[WAL_NpTransactionPay] (
    [Id]                  BIGINT           IDENTITY (1, 1) NOT NULL,
    [NpTranId]            BIGINT           NOT NULL,
    [vpc_MerchTxnRef]     NVARCHAR (50)    NULL,
    [vpc_Amount]          DECIMAL (28)     NOT NULL,
    [vpc_OrderInfo]       NVARCHAR (50)    NOT NULL,
    [vpc_TransactionNo]   NVARCHAR (50)    NULL,
    [vpc_BatchNo]         NVARCHAR (50)    NULL,
    [vpc_AcqResponseCode] NVARCHAR (50)    NULL,
    [vpc_AdditionalData]  NVARCHAR (100)   NULL,
    [vpc_ResponseCode]    INT              NULL,
    [vpc_Message]         NVARCHAR (150)   NULL,
    [TranPayDt]           DATETIME         NULL,
    [oid]                 UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_NpTransactionPay_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_NpTransactionPay] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_WAL_NpTransactionPay_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

