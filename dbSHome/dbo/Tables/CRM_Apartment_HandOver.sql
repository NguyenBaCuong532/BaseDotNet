CREATE TABLE [dbo].[CRM_Apartment_HandOver] (
    [HandOverId]      BIGINT           IDENTITY (1, 1) NOT NULL,
    [TitleHandOver]   NVARCHAR (200)   NULL,
    [OutDateHandOver] DATETIME         NULL,
    [RequestDateCus]  DATETIME         NULL,
    [BuildingCd]      NVARCHAR (50)    NULL,
    [ProjectCd]       NVARCHAR (50)    NULL,
    [IsClose]         BIT              NULL,
    [HandOverStatus]  INT              NULL,
    [Note]            NVARCHAR (500)   NULL,
    [Created]         DATETIME         NULL,
    [CreatedBy]       NVARCHAR (50)    NULL,
    [Modified]        DATETIME         NULL,
    [ModifiedBy]      NVARCHAR (50)    NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Apartment_HandOver_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Apartment_HandOver_1] PRIMARY KEY CLUSTERED ([HandOverId] ASC),
    CONSTRAINT [FK_CRM_Apartment_HandOver_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

