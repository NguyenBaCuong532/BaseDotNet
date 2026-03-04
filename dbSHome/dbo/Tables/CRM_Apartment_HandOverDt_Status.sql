CREATE TABLE [dbo].[CRM_Apartment_HandOverDt_Status] (
    [HandOverDtStatusId]   INT              NOT NULL,
    [HandOverDtStatusName] NVARCHAR (50)    NULL,
    [Color]                NVARCHAR (50)    NULL,
    [oid]                  UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Apartment_HandOverDt_Status_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Apartment_HandOverDt_Status] PRIMARY KEY CLUSTERED ([HandOverDtStatusId] ASC),
    CONSTRAINT [FK_CRM_Apartment_HandOverDt_Status_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

