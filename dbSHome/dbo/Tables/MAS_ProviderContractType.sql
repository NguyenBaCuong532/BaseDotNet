CREATE TABLE [dbo].[MAS_ProviderContractType] (
    [ProviderCd]     NVARCHAR (50)    NOT NULL,
    [ContractTypeId] INT              NOT NULL,
    [SysDate]        DATETIME         CONSTRAINT [DF_MAS_ProviderContractType_SysDate] DEFAULT (getdate()) NOT NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_ProviderContractType_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_ProviderContractType] PRIMARY KEY CLUSTERED ([ProviderCd] ASC, [ContractTypeId] ASC),
    CONSTRAINT [FK_MAS_ProviderContractType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

