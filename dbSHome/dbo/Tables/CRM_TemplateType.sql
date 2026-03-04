CREATE TABLE [dbo].[CRM_TemplateType] (
    [TemplateTypeId]   INT              NULL,
    [TemplateTypeName] NVARCHAR (255)   NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_TemplateType_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_TemplateType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

