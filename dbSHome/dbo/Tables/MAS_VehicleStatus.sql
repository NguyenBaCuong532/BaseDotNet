CREATE TABLE [dbo].[MAS_VehicleStatus] (
    [StatusId]        INT              NOT NULL,
    [StatusName]      NVARCHAR (100)   NULL,
    [StatusNameLable] NVARCHAR (100)   NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_VehicleStatus_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Vehicles] PRIMARY KEY CLUSTERED ([StatusId] ASC),
    CONSTRAINT [FK_MAS_VehicleStatus_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

