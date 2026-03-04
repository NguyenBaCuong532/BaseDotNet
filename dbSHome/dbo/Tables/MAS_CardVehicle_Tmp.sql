CREATE TABLE [dbo].[MAS_CardVehicle_Tmp] (
    [CardVehicleId] BIGINT           NULL,
    [CardId]        INT              NULL,
    [CustId]        NVARCHAR (50)    NULL,
    [VehicleNo]     NVARCHAR (50)    NULL,
    [Status]        INT              NULL,
    [ApartmentId]   INT              NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardVehicle_Tmp_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    [cardOid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_MAS_CardVehicle_Tmp_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

