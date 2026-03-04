CREATE TABLE [dbo].[WAL_BkTransaction] (
    [BkTransactionId]          NVARCHAR (50)    NOT NULL,
    [CustomerID]               NVARCHAR (50)    NOT NULL,
    [DestinationAccountNumber] NVARCHAR (50)    NOT NULL,
    [Period]                   NVARCHAR (100)   NULL,
    [Amount]                   DECIMAL (28)     NOT NULL,
    [PaymentDt]                DATETIME         NULL,
    [Description]              NVARCHAR (150)   NULL,
    [PaymentTypeID]            INT              NULL,
    [TnxSource]                NVARCHAR (200)   NULL,
    [TicketNo]                 NVARCHAR (50)    NULL,
    [IsTrans]                  BIT              NOT NULL,
    [oid]                      UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_BkTransaction_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]               UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_BkTransaction] PRIMARY KEY CLUSTERED ([BkTransactionId] ASC),
    CONSTRAINT [FK_WAL_BkTransaction_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

