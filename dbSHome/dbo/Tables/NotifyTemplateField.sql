CREATE TABLE [dbo].[NotifyTemplateField] (
    [id]         UNIQUEIDENTIFIER CONSTRAINT [DF_NotifyTemplateField_id] DEFAULT (newid()) NOT NULL,
    [tempId]     UNIQUEIDENTIFIER NOT NULL,
    [fieldId]    UNIQUEIDENTIFIER NOT NULL,
    [intOrder]   INT              NULL,
    [created_by] UNIQUEIDENTIFIER NULL,
    [created_at] DATETIME         CONSTRAINT [DF_NotifyTemplateField_created_at] DEFAULT (getdate()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_NotifyTemplateField] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_NotifyTemplateField_NotifyField] FOREIGN KEY ([fieldId]) REFERENCES [dbo].[NotifyField] ([fieldId]) ON DELETE CASCADE,
    CONSTRAINT [FK_NotifyTemplateField_NotifyTemplate] FOREIGN KEY ([tempId]) REFERENCES [dbo].[NotifyTemplate] ([tempId]) ON DELETE CASCADE,
    CONSTRAINT [FK_NotifyTemplateField_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bảng quan hệ giữa NotifyTemplate và NotifyField - lưu danh sách field được chọn cho mỗi template', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifyTemplateField';

