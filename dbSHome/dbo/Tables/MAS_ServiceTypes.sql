CREATE TABLE [dbo].[MAS_ServiceTypes] (
    [ServiceTypeId]   INT              NOT NULL,
    [ServiceTypeName] NVARCHAR (150)   NOT NULL,
    [ServiceType]     NVARCHAR (50)    NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_ServiceTypes_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_ServiceTypes] PRIMARY KEY CLUSTERED ([ServiceTypeId] ASC),
    CONSTRAINT [FK_MAS_ServiceTypes_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

