CREATE TABLE [dbo].[vehicleno_riverside] (
    [CardId]     NVARCHAR (10)    NULL,
    [VehicleNo]  NVARCHAR (15)    NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_vehicleno_riverside_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_vehicleno_riverside_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

