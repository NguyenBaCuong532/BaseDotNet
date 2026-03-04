CREATE TABLE [dbo].[CRM_Brand] (
    [BrandId]     INT              NULL,
    [CreatedBy]   NVARCHAR (50)    NULL,
    [CreatedTime] DATE             NULL,
    [PhoneNo]     NCHAR (15)       NULL,
    [BrandName]   NVARCHAR (255)   NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Brand_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_Brand_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

