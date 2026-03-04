CREATE TABLE [dbo].[par_vehicle_daily_type] (
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_ServicePrice_VehicleDailyBlockType_Oid] DEFAULT (newid()) NOT NULL,
    [config_code] NVARCHAR (50)    NOT NULL,
    [config_name] NVARCHAR (100)   NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ServicePrice_VehicleDailyBlockType] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_vehicle_daily_type_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cấu hình giá dịch vụ - Gửi xe ngày - đơn vị tính', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle_daily_type';

