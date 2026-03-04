CREATE TABLE [dbo].[WAL_CrdTransactionRecharge] (
    [Id]           INT              IDENTITY (1, 1) NOT NULL,
    [CrdTransId]   INT              NOT NULL,
    [RechargeCode] NVARCHAR (50)    NOT NULL,
    [CardSerial]   NVARCHAR (50)    NOT NULL,
    [IsRec]        BIT              NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_CrdTransactionRecharge_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_CrdTransactionRecharge] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_WAL_CrdTransactionRecharge_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

