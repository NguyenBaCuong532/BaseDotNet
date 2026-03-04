CREATE TABLE [dbo].[mas_payment_priority_configs] (
    [oid]                UNIQUEIDENTIFIER NOT NULL,
    [project_code]       NVARCHAR (50)    NOT NULL,
    [payment_service_id] UNIQUEIDENTIFIER NOT NULL,
    [is_collect_fee]     BIT              CONSTRAINT [DF_mas_payment_priority_configs_is_collect_fee] DEFAULT ((1)) NOT NULL,
    [priority_order]     INT              NOT NULL,
    [created_by]         UNIQUEIDENTIFIER NULL,
    [created_time]       DATETIME         CONSTRAINT [DF_mas_payment_priority_configs_created_time] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]   UNIQUEIDENTIFIER NULL,
    [last_modified_time] DATETIME         CONSTRAINT [DF_mas_payment_priority_configs_last_modified_time] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_mas_payment_priority_configs] PRIMARY KEY CLUSTERED ([oid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Thứ tự ưu tiên', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_payment_priority_configs', @level2type = N'COLUMN', @level2name = N'priority_order';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Có thực hiện thu phí hay không', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_payment_priority_configs', @level2type = N'COLUMN', @level2name = N'is_collect_fee';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID dịch vụ lấy từ mas_payment_services', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_payment_priority_configs', @level2type = N'COLUMN', @level2name = N'payment_service_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Thứ tự ưu tiên thanh toán các dịch vụ căn hộ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_payment_priority_configs';

