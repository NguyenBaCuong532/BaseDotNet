CREATE TABLE [dbo].[CRM_CustStatus] (
    [CustStatusId]   INT              NULL,
    [CustStatusName] NVARCHAR (50)    NULL,
    [Color]          NVARCHAR (50)    NULL,
    [isActived]      BIT              NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_CustStatus_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_CustStatus_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

