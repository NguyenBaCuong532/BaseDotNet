CREATE TABLE [dbo].[NotifyField] (
    [fieldId]    UNIQUEIDENTIFIER CONSTRAINT [DF_NotifyField_fieldId] DEFAULT (newid()) NOT NULL,
    [fieldName]  NVARCHAR (100)   NOT NULL,
    [fieldLabel] NVARCHAR (200)   NULL,
    [formulaId]  UNIQUEIDENTIFIER NOT NULL,
    [field_type] NVARCHAR (50)    NULL,
    [app_st]     INT              CONSTRAINT [DF_NotifyField_app_st] DEFAULT ((1)) NULL,
    [created_by] UNIQUEIDENTIFIER NULL,
    [created_at] DATETIME         CONSTRAINT [DF_NotifyField_created_at] DEFAULT (getdate()) NOT NULL,
    [updated_by] UNIQUEIDENTIFIER NULL,
    [updated_at] DATETIME         NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_NotifyField] PRIMARY KEY CLUSTERED ([fieldId] ASC),
    CONSTRAINT [FK_NotifyField_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Công thức SQL để lấy giá trị. Có thể chứa các placeholder: {empId}, {n_id}, {sourceId}, {custId}, {organizeId}. Ví dụ: SELECT salary FROM SalaryInfo WHERE empId = {empId}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifyField', @level2type = N'COLUMN', @level2name = N'formulaId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tên field (ví dụ: salary, date, amount) - dùng trong template như {salary}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifyField', @level2type = N'COLUMN', @level2name = N'fieldName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bảng danh mục các field có thể sử dụng trong template thông báo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifyField';

