CREATE TABLE [dbo].[par_vehicle_type] (
    [oid]                UNIQUEIDENTIFIER CONSTRAINT [DF_ServicePrice_VehicleType_Oid] DEFAULT (newid()) NOT NULL,
    [project_code]       NVARCHAR (50)    NULL,
    [config_name]        NVARCHAR (50)    NOT NULL,
    [block_pricing]      BIT              CONSTRAINT [DF_ServicePrice_VehicleType_BlockPricing] DEFAULT ((0)) NOT NULL,
    [vehicle_type_id]    NVARCHAR (50)    NULL,
    [sort_order]         INT              CONSTRAINT [DF_ServicePrice_VehicleType_SortOrder] DEFAULT ((0)) NOT NULL,
    [created_user]       UNIQUEIDENTIFIER NULL,
    [created_date]       DATETIME         CONSTRAINT [DF_par_vehicle_type_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]   UNIQUEIDENTIFIER NULL,
    [last_modified_date] DATETIME         CONSTRAINT [DF_par_vehicle_type_last_modified_date] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ServicePrice_VehicleType] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_vehicle_type_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cấu hình giá dịch vụ - Gửi xe - Loại phương tiện', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle_type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Danh sách các mã loại xe trong nhóm', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle_type', @level2type = N'COLUMN', @level2name = N'vehicle_type_id';

