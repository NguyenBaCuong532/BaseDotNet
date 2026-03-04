CREATE TABLE [dbo].[TRS_PayRegBillUrl] (
    [PayRegBillId] INT              NOT NULL,
    [BillUrl]      NVARCHAR (300)   NOT NULL,
    [BillTitle]    NVARCHAR (250)   NULL,
    [PayServiceId] INT              NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_PayRegBillUrl_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_PayRegBillUrl] PRIMARY KEY CLUSTERED ([PayRegBillId] ASC, [BillUrl] ASC),
    CONSTRAINT [FK_TRS_PayRegBillUrl_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

