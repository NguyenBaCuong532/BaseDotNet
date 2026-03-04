CREATE TABLE [dbo].[par_service_price_type] (
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_par_service_price_type_oid] DEFAULT (newid()) NOT NULL,
    [config_code]   NVARCHAR (50)    NOT NULL,
    [config_name]   NVARCHAR (50)    NOT NULL,
    [is_step_price] BIT              CONSTRAINT [DF_par_service_price_type_is_step_price] DEFAULT ((0)) NOT NULL,
    [sort_order]    INT              CONSTRAINT [DF_par_service_price_type_sort_order] DEFAULT ((0)) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_par_service_price_type] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_service_price_type_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Áp dụng tính giá bậc thang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_service_price_type', @level2type = N'COLUMN', @level2name = N'is_step_price';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Loại giá dịch vụ (kinh doanh, sinh hoạt...)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_service_price_type';

