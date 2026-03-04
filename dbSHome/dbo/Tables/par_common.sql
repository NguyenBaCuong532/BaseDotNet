CREATE TABLE [dbo].[par_common] (
    [oid]                    UNIQUEIDENTIFIER CONSTRAINT [DF_ServicePrice_Common_Oid] DEFAULT (newid()) NOT NULL,
    [project_code]           NVARCHAR (50)    NOT NULL,
    [par_residence_type_oid] UNIQUEIDENTIFIER NOT NULL,
    [service_name]           NVARCHAR (200)   NOT NULL,
    [unit_measure]           NVARCHAR (50)    NOT NULL,
    [value]                  DECIMAL (18, 4)  NOT NULL,
    [effective_date]         DATETIME         NULL,
    [expiry_date]            DATETIME         NULL,
    [tax_percent]            DECIMAL (18, 2)  CONSTRAINT [DF_par_common_tax_percent] DEFAULT ((0)) NOT NULL,
    [note]                   NVARCHAR (500)   NULL,
    [is_active]              BIGINT           CONSTRAINT [DF_par_common_is_active] DEFAULT ((0)) NOT NULL,
    [created_user]           UNIQUEIDENTIFIER NOT NULL,
    [created_date]           DATETIME         CONSTRAINT [DF_ServicePrice_Common_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]       UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date]     DATETIME         CONSTRAINT [DF_ServicePrice_Common_UpdatedDate] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]             UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ServicePrice_Common] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_common_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày hết hiệu lực', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_common', @level2type = N'COLUMN', @level2name = N'expiry_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày có hiệu lực', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_common', @level2type = N'COLUMN', @level2name = N'effective_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Giá tiền', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_common', @level2type = N'COLUMN', @level2name = N'value';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Đơn vị tính', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_common', @level2type = N'COLUMN', @level2name = N'unit_measure';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cấu hình giá dịch vụ chung', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_common';

