CREATE TABLE [dbo].[CRM_Membership] (
    [CustId]      NVARCHAR (50)    NULL,
    [GroupId]     INT              NULL,
    [CreatedTime] DATE             NULL,
    [CreatedBy]   NVARCHAR (50)    NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Membership_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_Membership_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

