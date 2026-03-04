CREATE TABLE [dbo].[CRM_Apartment_HandOver_WorkStatus] (
    [WorkStatusId]   INT              NOT NULL,
    [WorkStatusName] NVARCHAR (50)    NULL,
    [Color]          NVARCHAR (50)    NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Apartment_HandOver_WorkStatus_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_HandOver_WorkStatus] PRIMARY KEY CLUSTERED ([WorkStatusId] ASC),
    CONSTRAINT [FK_CRM_Apartment_HandOver_WorkStatus_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

