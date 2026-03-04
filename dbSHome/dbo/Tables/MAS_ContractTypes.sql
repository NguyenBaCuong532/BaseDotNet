CREATE TABLE [dbo].[MAS_ContractTypes] (
    [ContractTypeId]   INT              NOT NULL,
    [ContractTypeCode] NVARCHAR (50)    NULL,
    [ContractTypeName] NVARCHAR (100)   NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_ContractTypes_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_ContractTypes] PRIMARY KEY CLUSTERED ([ContractTypeId] ASC),
    CONSTRAINT [FK_MAS_ContractTypes_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

