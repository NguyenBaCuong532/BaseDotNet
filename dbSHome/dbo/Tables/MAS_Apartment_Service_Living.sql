CREATE TABLE [dbo].[MAS_Apartment_Service_Living] (
    [LivingId]         INT              IDENTITY (1, 1) NOT NULL,
    [LivingTypeId]     INT              NULL,
    [ProjectCd]        NVARCHAR (30)    NULL,
    [ProviderCd]       NVARCHAR (50)    NULL,
    [ApartmentId]      INT              NOT NULL,
    [ContractNo]       NVARCHAR (50)    NULL,
    [ContractDt]       DATE             NULL,
    [IsDocumentUpload] BIT              NULL,
    [EmployeeCd]       NVARCHAR (50)    NULL,
    [DeliverName]      NVARCHAR (150)   NULL,
    [CustId]           NVARCHAR (50)    NULL,
    [CustName]         NVARCHAR (250)   NULL,
    [CustPhone]        NVARCHAR (150)   NULL,
    [Note]             NVARCHAR (350)   NULL,
    [MeterSeri]        NVARCHAR (50)    NULL,
    [MeterDate]        DATE             NULL,
    [MeterNum]         INT              NULL,
    [MeterLastDt]      DATE             NULL,
    [MeterLastNum]     INT              NULL,
    [AccrualToDt]      DATE             NULL,
    [PayLastDt]        DATE             NULL,
    [IsClose]          BIT              NULL,
    [CloseDt]          DATETIME         NULL,
    [isMbusLink]       BIT              NULL,
    [sysDate]          DATETIME         NULL,
    [NumPersonWater]   INT              NULL,
    [IsActive]         BIT              CONSTRAINT [DF_MAS_Apartment_Service_Living_IsActive_1] DEFAULT ((0)) NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Apartment_Service_Living_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    [apartOid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Apartment_Service_Living] PRIMARY KEY CLUSTERED ([LivingId] ASC),
    CONSTRAINT [FK_MAS_Apartment_Service_Living_apartOid] FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments] ([oid]),
    CONSTRAINT [FK_MAS_Apartment_Service_Living_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);










GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartment_Service_Living_MeterSeri]
    ON [dbo].[MAS_Apartment_Service_Living]([MeterSeri] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartment_Service_Living_LivingTypeId]
    ON [dbo].[MAS_Apartment_Service_Living]([LivingTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartment_Service_Living_ApartmentId]
    ON [dbo].[MAS_Apartment_Service_Living]([ApartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MASL_Apt_LivingType]
    ON [dbo].[MAS_Apartment_Service_Living]([ApartmentId] ASC, [LivingTypeId] ASC)
    INCLUDE([NumPersonWater]);

