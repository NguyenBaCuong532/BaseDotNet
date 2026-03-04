CREATE TABLE [dbo].[par_electric_detail] (
    [oid]                        UNIQUEIDENTIFIER CONSTRAINT [DF_par_electric_detail_oid] DEFAULT (newid()) NOT NULL,
    [par_electric_oid]           UNIQUEIDENTIFIER NOT NULL,
    [par_service_price_type_oid] UNIQUEIDENTIFIER NOT NULL,
    [config_name]                NVARCHAR (100)   NOT NULL,
    [start_value]                DECIMAL (18)     NULL,
    [end_value]                  DECIMAL (18)     NULL,
    [unit_price]                 DECIMAL (18, 2)  NOT NULL,
    [sort_order]                 INT              CONSTRAINT [DF_par_electric_detail_sort_order] DEFAULT ((0)) NOT NULL,
    [created_user]               UNIQUEIDENTIFIER NOT NULL,
    [created_date]               DATETIME         CONSTRAINT [DF_par_electric_detail_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]           UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date]         DATETIME         CONSTRAINT [DF_par_electric_detail_last_modified_date] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]                 UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_par_electric_detail] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_electric_detail_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cấu hình giá dịch vụ - Điện - chi tiết', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_electric_detail';

