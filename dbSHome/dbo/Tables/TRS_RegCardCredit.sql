CREATE TABLE [dbo].[TRS_RegCardCredit] (
    [RegCardCreditId] INT              IDENTITY (1, 1) NOT NULL,
    [RequestId]       INT              NOT NULL,
    [Cif_No2]         NVARCHAR (50)    NOT NULL,
    [CreditLimit]     FLOAT (53)       NULL,
    [SalaryAvg]       INT              NULL,
    [IsSalaryTranfer] BIT              NULL,
    [ResidenProvince] NVARCHAR (100)   NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_RegCardCredit_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_RegCardCredit] PRIMARY KEY CLUSTERED ([RegCardCreditId] ASC),
    CONSTRAINT [FK_TRS_RegCardCredit_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

