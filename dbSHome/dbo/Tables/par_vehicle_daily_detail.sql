CREATE TABLE [dbo].[par_vehicle_daily_detail] (
    [oid]                        UNIQUEIDENTIFIER CONSTRAINT [DF_ServicePrice_VehicleDailyBlock_Oid] DEFAULT (newid()) NOT NULL,
    [par_vehicle_daily_oid]      UNIQUEIDENTIFIER NOT NULL,
    [par_vehicle_daily_type_oid] UNIQUEIDENTIFIER NULL,
    [config_name]                NVARCHAR (50)    NULL,
    [start_value]                INT              NULL,
    [end_value]                  INT              NULL,
    [start_time]                 TIME (7)         NULL,
    [end_time]                   TIME (7)         NULL,
    [unit_price]                 DECIMAL (18)     CONSTRAINT [DF_par_vehicle_daily_detail_unit_price] DEFAULT ((0)) NOT NULL,
    [note]                       NVARCHAR (200)   NULL,
    [created_user]               UNIQUEIDENTIFIER NOT NULL,
    [created_date]               DATETIME         CONSTRAINT [DF_ServicePrice_VehicleDailyBlock_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]           UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date]         DATETIME         CONSTRAINT [DF_ServicePrice_VehicleDailyBlock_LastModifiedDate] DEFAULT (getdate()) NOT NULL,
    [sort_order]                 INT              CONSTRAINT [DF_par_vehicle_daily_detail_sort_order] DEFAULT ((0)) NOT NULL,
    [tenant_oid]                 UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ServicePrice_VehicleDailyBlock] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_vehicle_daily_detail_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cấu hình giá dịch vụ - Gửi xe ngày - chi tiết', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle_daily_detail';

