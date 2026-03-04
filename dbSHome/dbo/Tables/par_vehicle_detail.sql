CREATE TABLE [dbo].[par_vehicle_detail] (
    [oid]                  UNIQUEIDENTIFIER CONSTRAINT [DF_par_vehicle_detail_oid] DEFAULT (newid()) NOT NULL,
    [par_vehicle_oid]      UNIQUEIDENTIFIER NOT NULL,
    [par_vehicle_type_oid] UNIQUEIDENTIFIER NOT NULL,
    [config_name]          NVARCHAR (100)   NOT NULL,
    [start_value]          DECIMAL (18)     NOT NULL,
    [end_value]            DECIMAL (18)     NOT NULL,
    [unit_price]           DECIMAL (18)     NOT NULL,
    [sort_order]           INT              CONSTRAINT [DF_par_vehicle_detail_sort_order] DEFAULT ((0)) NOT NULL,
    [created_user]         UNIQUEIDENTIFIER NOT NULL,
    [created_date]         DATETIME         CONSTRAINT [DF_par_vehicle_detail_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]     UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date]   DATETIME         CONSTRAINT [DF_par_vehicle_detail_last_modified_date] DEFAULT (getdate()) NOT NULL,
    [vehicleTypeId]        NVARCHAR (50)    NULL,
    [tenant_oid]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_par_vehicle_detail] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_vehicle_detail_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);










GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cấu hình giá dịch vụ - Gửi xe tháng - chi tiết', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle_detail';

