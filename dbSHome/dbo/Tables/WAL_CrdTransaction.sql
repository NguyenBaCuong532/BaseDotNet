CREATE TABLE [dbo].[WAL_CrdTransaction] (
    [CrdTransId]   INT              IDENTITY (1, 1) NOT NULL,
    [UserID]       NVARCHAR (50)    NOT NULL,
    [TxnId]        INT              NOT NULL,
    [ProviderId]   INT              NULL,
    [cardValue]    INT              NOT NULL,
    [Quantity]     INT              NULL,
    [TnxDt]        DATETIME         NULL,
    [IsTrans]      BIT              NULL,
    [ClientId]     NVARCHAR (50)    NULL,
    [promotion]    FLOAT (53)       NULL,
    [promotionAmt] INT              NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_CrdTransaction_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_CrdTransaction] PRIMARY KEY CLUSTERED ([CrdTransId] ASC),
    CONSTRAINT [FK_WAL_CrdTransaction_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

