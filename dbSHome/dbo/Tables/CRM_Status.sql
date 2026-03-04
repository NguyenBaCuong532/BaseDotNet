CREATE TABLE [dbo].[CRM_Status] (
    [statusKey]  NVARCHAR (50)    NOT NULL,
    [statusId]   INT              NOT NULL,
    [statusName] NVARCHAR (50)    NOT NULL,
    [color]      NVARCHAR (50)    NULL,
    [isActived]  BIT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Status_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Status] PRIMARY KEY CLUSTERED ([statusKey] ASC, [statusId] ASC),
    CONSTRAINT [FK_CRM_Status_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

