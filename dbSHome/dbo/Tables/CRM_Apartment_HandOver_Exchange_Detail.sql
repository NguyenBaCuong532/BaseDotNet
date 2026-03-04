CREATE TABLE [dbo].[CRM_Apartment_HandOver_Exchange_Detail] (
    [ExchangeDetailId] BIGINT           IDENTITY (1, 1) NOT NULL,
    [ExchangeId]       BIGINT           NULL,
    [Content]          NVARCHAR (500)   NULL,
    [Type]             INT              NULL,
    [FileName]         NVARCHAR (100)   NULL,
    [FileSize]         NVARCHAR (100)   NULL,
    [Icon]             NVARCHAR (100)   NULL,
    [LinkFile]         NVARCHAR (500)   NULL,
    [UserTagNames]     NVARCHAR (500)   NULL,
    [UserTags]         NVARCHAR (100)   NULL,
    [Created]          DATETIME         NULL,
    [CreatedBy]        NVARCHAR (50)    NULL,
    [Modified]         DATETIME         NULL,
    [ModifiedBy]       NVARCHAR (50)    NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Apartment_HandOver_Exchange_Detail_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Apartment_HandOver_Exchange_Detail] PRIMARY KEY CLUSTERED ([ExchangeDetailId] ASC),
    CONSTRAINT [FK_CRM_Apartment_HandOver_Exchange_Detail_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

