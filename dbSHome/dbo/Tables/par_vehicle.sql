CREATE TABLE [dbo].[par_vehicle] (
    [oid]                    UNIQUEIDENTIFIER CONSTRAINT [DF_par_vehicle_oid] DEFAULT (newid()) NOT NULL,
    [project_code]           NVARCHAR (50)    NOT NULL,
    [par_residence_type_oid] UNIQUEIDENTIFIER NOT NULL,
    [effective_date]         DATETIME         NULL,
    [expiry_date]            DATETIME         NULL,
    [register_value]         INT              NULL,
    [register_by_day]        BIT              NULL,
    [cancel_value]           INT              NULL,
    [cancel_by_day]          BIT              NULL,
    [note]                   NVARCHAR (200)   NULL,
    [is_active]              BIT              CONSTRAINT [DF_ServicePrice_Vehicle_IsActive] DEFAULT ((0)) NOT NULL,
    [created_user]           UNIQUEIDENTIFIER NOT NULL,
    [created_date]           DATETIME         CONSTRAINT [DF_ServicePrice_Vehicle_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]       UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date]     DATETIME         CONSTRAINT [DF_ServicePrice_Vehicle_LastModifiedDate] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]             UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ServicePrice_Vehicle] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_vehicle_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hủy - Tính theo ngày', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle', @level2type = N'COLUMN', @level2name = N'cancel_by_day';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Giá trị cấu hình khi hủy - Nếu vượt quá giá trị sẽ tính là 1 tháng', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle', @level2type = N'COLUMN', @level2name = N'cancel_value';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Đăng ký - Tính theo ngày', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle', @level2type = N'COLUMN', @level2name = N'register_by_day';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Giá trị cấu hình khi đăng ký - Nếu vượt quá giá trị sẽ tính là 1 tháng', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle', @level2type = N'COLUMN', @level2name = N'register_value';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày hết hiệu lực', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle', @level2type = N'COLUMN', @level2name = N'expiry_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày có hiệu lực', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle', @level2type = N'COLUMN', @level2name = N'effective_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cấu hình giá dịch vụ - Gửi xe tháng', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_vehicle';

