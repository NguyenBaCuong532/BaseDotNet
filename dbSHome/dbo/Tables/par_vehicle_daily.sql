CREATE TABLE [dbo].[par_vehicle_daily] (
    [oid]                  UNIQUEIDENTIFIER CONSTRAINT [DF_ServicePrice_VehicleDaily_OId] DEFAULT (newid()) NOT NULL,
    [par_vehicle_type_oid] UNIQUEIDENTIFIER NULL,
    [project_code]         NVARCHAR (50)    NOT NULL,
    [effective_date]       DATETIME         NULL,
    [expiry_date]          DATETIME         NULL,
    [note]                 NVARCHAR (200)   NULL,
    [is_active]            BIT              CONSTRAINT [DF_ServicePrice_VehicleDaily_IsActive] DEFAULT ((0)) NOT NULL,
    [created_user]         UNIQUEIDENTIFIER NULL,
    [created_date]         DATETIME         CONSTRAINT [DF_par_vehicle_daily_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]     UNIQUEIDENTIFIER NULL,
    [last_modified_date]   DATETIME         CONSTRAINT [DF_par_vehicle_daily_last_modified_date] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ServicePrice_VehicleDaily] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_vehicle_daily_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày hết hiệu lực', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle_daily', @level2type = N'COLUMN', @level2name = N'expiry_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày có hiệu lực', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle_daily', @level2type = N'COLUMN', @level2name = N'effective_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cấu hình giá dịch vụ - Gửi xe ngày', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle_daily';

