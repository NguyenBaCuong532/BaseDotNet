CREATE TABLE [dbo].[TRS_PayRegBill] (
    [PayRegBillId] INT              IDENTITY (1, 1) NOT NULL,
    [BillYear]     INT              NOT NULL,
    [BillMonth]    INT              NULL,
    [RegDt]        DATETIME         NULL,
    [RegSt]        INT              NULL,
    [ApartmentId]  INT              NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_PayRegBill_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    [apartOid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_PayRegBill] PRIMARY KEY CLUSTERED ([PayRegBillId] ASC),
    CONSTRAINT [FK_TRS_PayRegBill_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

