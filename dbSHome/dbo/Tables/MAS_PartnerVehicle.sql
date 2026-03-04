CREATE TABLE [dbo].[MAS_PartnerVehicle] (
    [VehicleId]    BIGINT           IDENTITY (1, 1) NOT NULL,
    [ProjectCd]    NVARCHAR (40)    NOT NULL,
    [PartnerId]    BIGINT           NOT NULL,
    [CardCode]     NVARCHAR (50)    NOT NULL,
    [PartnerName]  NVARCHAR (100)   NOT NULL,
    [OwnerName]    NVARCHAR (100)   NOT NULL,
    [VehicleType]  INT              NOT NULL,
    [LicensePlate] NVARCHAR (20)    NOT NULL,
    [StartDate]    DATETIME         NOT NULL,
    [Status]       INT              CONSTRAINT [DF_MAS_PartnerVehicle_Status] DEFAULT ((1)) NOT NULL,
    [Create_dt]    DATETIME         CONSTRAINT [DF_MAS_PartnerVehicle_CreateDt] DEFAULT (getdate()) NOT NULL,
    [CreateBy]     NVARCHAR (100)   NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([VehicleId] ASC),
    CONSTRAINT [FK_MAS_PartnerVehicle_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_PartnerVehicle_Status]
    ON [dbo].[MAS_PartnerVehicle]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_PartnerVehicle_Project_Partner]
    ON [dbo].[MAS_PartnerVehicle]([ProjectCd] ASC, [PartnerId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_MAS_PartnerVehicle_LicensePlate]
    ON [dbo].[MAS_PartnerVehicle]([LicensePlate] ASC);

