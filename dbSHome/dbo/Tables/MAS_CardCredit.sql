CREATE TABLE [dbo].[MAS_CardCredit] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [CardId]          INT              NOT NULL,
    [Cif_No2]         NVARCHAR (50)    NOT NULL,
    [CreditLimit]     FLOAT (53)       NULL,
    [SalaryAvg]       INT              NULL,
    [IsSalaryTranfer] BIT              NULL,
    [ResidenProvince] NVARCHAR (100)   NULL,
    [AsignDate]       DATETIME         NULL,
    [Status]          BIT              NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardCredit_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    [cardOid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CardCredit] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MAS_CardCredit_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

