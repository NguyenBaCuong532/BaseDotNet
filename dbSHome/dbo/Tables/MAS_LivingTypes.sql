CREATE TABLE [dbo].[MAS_LivingTypes] (
    [LivingTypeId]   INT              NOT NULL,
    [LivingTypeName] NVARCHAR (100)   NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_LivingTypes_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_LivingTypes] PRIMARY KEY CLUSTERED ([LivingTypeId] ASC),
    CONSTRAINT [FK_MAS_LivingTypes_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

