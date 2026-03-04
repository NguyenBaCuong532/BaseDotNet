CREATE TABLE [dbo].[PAR_BlockVehicleDaily] (
    [VehicleDailyId] INT              IDENTITY (1, 1) NOT NULL,
    [ProjectCd]      NVARCHAR (30)    NULL,
    [VehicleTypeId]  INT              NULL,
    [Note0]          NVARCHAR (50)    NULL,
    [Block0]         INT              NULL,
    [Price0]         DECIMAL (18)     NULL,
    [Note1]          NVARCHAR (50)    NULL,
    [Block1]         INT              NULL,
    [Price1]         DECIMAL (18)     NULL,
    [Note2]          NVARCHAR (50)    NULL,
    [Price2]         DECIMAL (18)     NULL,
    [IsFree]         BIT              NULL,
    [Unit]           NVARCHAR (50)    NULL,
    [IsUsed]         BIT              NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_PAR_BlockVehicleDaily_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_PAR_BlockVehicleDaily] PRIMARY KEY CLUSTERED ([VehicleDailyId] ASC),
    CONSTRAINT [FK_PAR_BlockVehicleDaily_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

