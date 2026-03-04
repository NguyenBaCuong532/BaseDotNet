CREATE TABLE [dbo].[MAS_VehicleTypes] (
    [VehicleTypeId]   INT              NOT NULL,
    [VehicleTypeName] NVARCHAR (100)   NULL,
    [ServiceId]       INT              NULL,
    [icon]            NVARCHAR (350)   NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_VehicleTypes_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_VehicleTypes] PRIMARY KEY CLUSTERED ([VehicleTypeId] ASC),
    CONSTRAINT [FK_MAS_VehicleTypes_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

