CREATE TABLE [dbo].[CRM_Template] (
    [TemplateId]      INT              IDENTITY (1, 1) NOT NULL,
    [TransTypeId]     INT              NULL,
    [TemplateTypeId]  INT              NULL,
    [CreatedBy]       NVARCHAR (50)    NULL,
    [CreatedTime]     DATE             NULL,
    [TemplateName]    NVARCHAR (255)   NOT NULL,
    [UpdatedBy]       NVARCHAR (50)    NULL,
    [UpdatedTime]     DATE             NULL,
    [TemplateContent] NVARCHAR (MAX)   NULL,
    [TemplateUrl]     NVARCHAR (350)   NULL,
    [isShared]        BIT              CONSTRAINT [DF_CRM_Template_isPublish] DEFAULT ((0)) NULL,
    [thumbnailUrl]    NVARCHAR (350)   NULL,
    [isHtml]          BIT              NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Template_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_Template_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ__CRM_Temp__B8E1740811BAFF5E] UNIQUE NONCLUSTERED ([TemplateName] ASC, [TemplateTypeId] ASC)
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0: SMS, 1: Email', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CRM_Template', @level2type = N'COLUMN', @level2name = N'TransTypeId';

