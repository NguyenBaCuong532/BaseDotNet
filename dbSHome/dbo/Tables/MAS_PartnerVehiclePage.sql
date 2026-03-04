CREATE TABLE [dbo].[MAS_PartnerVehiclePage] (
    [VehicleId]    BIGINT           IDENTITY (1, 1) NOT NULL,
    [ProjectCd]    NVARCHAR (40)    NOT NULL,
    [PartnerId]    BIGINT           NOT NULL,
    [CardCode]     NVARCHAR (50)    NOT NULL,
    [PartnerName]  NVARCHAR (100)   NOT NULL,
    [OwnerName]    NVARCHAR (100)   NOT NULL,
    [VehicleType]  INT              NOT NULL,
    [LicensePlate] NVARCHAR (20)    NOT NULL,
    [StartDate]    DATETIME         NOT NULL,
    [Status]       INT              NOT NULL,
    [Create_dt]    DATETIME         DEFAULT (getdate()) NOT NULL,
    [CreateBy]     NVARCHAR (100)   NOT NULL,
    [Brand]        NVARCHAR (50)    CONSTRAINT [DF_MAS_PartnerVehiclePage_Brand] DEFAULT (N'-') NOT NULL,
    [Color]        NVARCHAR (50)    NULL,
    [AttachFile]   NVARCHAR (MAX)   NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([VehicleId] ASC),
    CONSTRAINT [FK_MAS_PartnerVehiclePage_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_PartnerVehiclePage_Status]
    ON [dbo].[MAS_PartnerVehiclePage]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_PartnerVehiclePage_Project_Partner]
    ON [dbo].[MAS_PartnerVehiclePage]([ProjectCd] ASC, [PartnerId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_MAS_PartnerVehiclePage_LicensePlate]
    ON [dbo].[MAS_PartnerVehiclePage]([LicensePlate] ASC);

