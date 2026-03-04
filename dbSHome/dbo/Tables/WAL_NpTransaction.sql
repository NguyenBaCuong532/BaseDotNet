CREATE TABLE [dbo].[WAL_NpTransaction] (
    [NpTranId]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [vpc_MerchTxnRef]    NVARCHAR (50)    NOT NULL,
    [vpc_OrderInfo]      NVARCHAR (50)    NOT NULL,
    [vpc_TicketNo]       NVARCHAR (50)    NOT NULL,
    [vpc_Amount]         DECIMAL (28)     NOT NULL,
    [vpc_PaymentGateway] NVARCHAR (150)   NULL,
    [vpc_CardType]       NVARCHAR (200)   NULL,
    [vpc_Token]          NVARCHAR (50)    NULL,
    [IsPayed]            BIT              NOT NULL,
    [TranDt]             DATETIME         NULL,
    [oid]                UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_NpTransaction_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_NpTransaction] PRIMARY KEY CLUSTERED ([vpc_MerchTxnRef] ASC),
    CONSTRAINT [FK_WAL_NpTransaction_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

