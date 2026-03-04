CREATE TABLE [dbo].[TRS_RegCardVehicle] (
    [RegCardVehicleId] INT              IDENTITY (1, 1) NOT NULL,
    [RequestId]        INT              NOT NULL,
    [VehicleTypeId]    INT              NULL,
    [VehicleNo]        NVARCHAR (10)    NULL,
    [ServiceId]        INT              NULL,
    [VehicleName]      NVARCHAR (50)    NULL,
    [sysdate]          DATETIME         CONSTRAINT [DF_TRS_RegCardVehicle_sysdate] DEFAULT (getdate()) NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_RegCardVehicle_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_RegCardVehicle] PRIMARY KEY CLUSTERED ([RegCardVehicleId] ASC),
    CONSTRAINT [FK_TRS_RegCardVehicle_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

