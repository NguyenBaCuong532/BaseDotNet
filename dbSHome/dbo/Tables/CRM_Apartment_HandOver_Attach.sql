CREATE TABLE [dbo].[CRM_Apartment_HandOver_Attach] (
    [AttachId]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [AttachName]       NVARCHAR (50)    NULL,
    [AttachSize]       NVARCHAR (100)   NULL,
    [AttachLink]       NVARCHAR (200)   NULL,
    [ExchangeId]       BIGINT           NULL,
    [ExchangeDetailId] BIGINT           NULL,
    [Type]             INT              NULL,
    [Created]          DATETIME         NULL,
    [CreatedBy]        NVARCHAR (50)    NULL,
    [Modified]         DATETIME         NULL,
    [ModifiedBy]       NVARCHAR (50)    NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Apartment_HandOver_Attach_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Apartment_HandOver_Attach] PRIMARY KEY CLUSTERED ([AttachId] ASC),
    CONSTRAINT [FK_CRM_Apartment_HandOver_Attach_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

