CREATE TABLE [dbo].[PAR_ServicePrice] (
    [ServicePriceId]  INT              IDENTITY (1, 1) NOT NULL,
    [ProjectCd]       NVARCHAR (30)    NULL,
    [TypeId]          INT              NULL,
    [ServiceTypeId]   INT              NULL,
    [ServiceTypeName] NVARCHAR (50)    NULL,
    [ServiceId]       INT              NULL,
    [ServiceName]     NVARCHAR (50)    NULL,
    [Price]           DECIMAL (18)     NULL,
    [Unit]            NVARCHAR (50)    NULL,
    [Note]            NVARCHAR (100)   NULL,
    [Price2]          DECIMAL (18)     NULL,
    [CalculateType]   INT              NULL,
    [IsFree]          BIT              NULL,
    [IsUsed]          BIT              NULL,
    [VehicleType]     INT              NULL,
    [Price_Rent]      DECIMAL (18)     NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_PAR_ServicePrice_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_PAR_ServicePrice] PRIMARY KEY CLUSTERED ([ServicePriceId] ASC),
    CONSTRAINT [FK_PAR_ServicePrice_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

