CREATE TABLE [dbo].[MAS_Service_Bank] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [ProjectCd]       NVARCHAR (50)    NULL,
    [Bank_Acc_Num]    NVARCHAR (50)    NULL,
    [Bank_Acc_Name]   NVARCHAR (100)   NULL,
    [Bank_Acc_Branch] NVARCHAR (100)   NULL,
    [Bank_Code]       NVARCHAR (50)    NULL,
    [bank_cif_no]     NVARCHAR (50)    NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Service_Bank_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Service_Bank] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MAS_Service_Bank_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

