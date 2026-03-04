CREATE TABLE [dbo].[TRS_Service_ContractDevice] (
    [DeviceId]       INT              IDENTITY (1, 1) NOT NULL,
    [ContractId]     INT              NOT NULL,
    [DeviceSerial]   NVARCHAR (100)   NULL,
    [DeviceName]     NVARCHAR (100)   NULL,
    [DeviceWarranty] DATE             NULL,
    [UserType]       NVARCHAR (250)   NULL,
    [UserName]       NVARCHAR (50)    NULL,
    [UserPassword]   NVARCHAR (50)    NULL,
    [MeterSeri]      NVARCHAR (50)    NULL,
    [MeterDateStart] DATE             NULL,
    [MeterNumStart]  FLOAT (53)       NULL,
    [sysDate]        DATETIME         NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_Service_ContractDevice_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_Service_ContractDevice] PRIMARY KEY CLUSTERED ([DeviceId] ASC),
    CONSTRAINT [FK_TRS_Service_ContractDevice_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

