CREATE TABLE [dbo].[MAS_Apartment_Service_Extend] (
    [ExtendId]         INT              IDENTITY (1, 1) NOT NULL,
    [ContractTypeId]   INT              NULL,
    [ProjectCd]        NVARCHAR (30)    NULL,
    [ProviderCd]       NVARCHAR (50)    NULL,
    [ApartmentId]      INT              NOT NULL,
    [ContractNo]       NVARCHAR (50)    NULL,
    [ContractDt]       DATE             NULL,
    [ContractUser]     NVARCHAR (50)    NULL,
    [ContractPassword] NVARCHAR (50)    NULL,
    [EmployeeCd]       NVARCHAR (50)    NULL,
    [DeviceSeri]       NVARCHAR (50)    NULL,
    [DeviceName]       NVARCHAR (50)    NULL,
    [DeviceWarranty]   NVARCHAR (50)    NULL,
    [PackPriceId]      INT              NULL,
    [CustId]           NVARCHAR (50)    NULL,
    [CustName]         NVARCHAR (250)   NULL,
    [CustPhone]        NVARCHAR (150)   NULL,
    [IsCompany]        BIT              NULL,
    [CompanyName]      NVARCHAR (150)   NULL,
    [CompanyRepresent] NVARCHAR (100)   NULL,
    [CompanyAddress]   NVARCHAR (250)   NULL,
    [CompanyCode]      NVARCHAR (50)    NULL,
    [AccrualToDt]      DATE             NULL,
    [PayLastDt]        DATE             NULL,
    [IsDocumentUpload] BIT              NULL,
    [IsClose]          BIT              NULL,
    [CloseDt]          DATETIME         NULL,
    [sysDate]          DATETIME         NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Apartment_Service_Extend_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    [apartOid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Apartment_Service_Extand] PRIMARY KEY CLUSTERED ([ExtendId] ASC),
    CONSTRAINT [FK_MAS_Apartment_Service_Extend_apartOid] FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments] ([oid]),
    CONSTRAINT [FK_MAS_Apartment_Service_Extend_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartment_Service_Extend_ApartmentId]
    ON [dbo].[MAS_Apartment_Service_Extend]([ApartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartment_Service_Extend_ProjectCd]
    ON [dbo].[MAS_Apartment_Service_Extend]([ProjectCd] ASC);

