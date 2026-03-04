CREATE TABLE [dbo].[service_request] (
    [id]               UNIQUEIDENTIFIER CONSTRAINT [DF_service_request_id] DEFAULT (newid()) NOT NULL,
    [request_code]     NVARCHAR (50)    NULL,
    [apartment_id]     BIGINT           NULL,
    [service_id]       UNIQUEIDENTIFIER NULL,
    [package_id]       UNIQUEIDENTIFIER NULL,
    [is_quick_support] BIT              NULL,
    [service_date]     DATE             NULL,
    [service_time]     TIME (7)         NULL,
    [speed_extra_id]   UNIQUEIDENTIFIER NULL,
    [estimated_amount] DECIMAL (18)     NULL,
    [status]           INT              CONSTRAINT [DF_service_request_status] DEFAULT ((0)) NULL,
    [created_dt]       DATETIME         CONSTRAINT [DF_service_request_created_dt] DEFAULT (getdate()) NULL,
    [created_by]       UNIQUEIDENTIFIER NULL,
    [approved_dt]      DATETIME         NULL,
    [updated_dt]       DATETIME         NULL,
    [updated_by]       UNIQUEIDENTIFIER NULL,
    [delete_dt]        DATETIME         NULL,
    [delete_by]        UNIQUEIDENTIFIER NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_service_request] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_service_request_service_speed_extra] FOREIGN KEY ([speed_extra_id]) REFERENCES [dbo].[service_speed_extra] ([id]),
    CONSTRAINT [FK_service_request_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);










GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0: Gửi yêu cầu
1: Chờ tiếp nhận
2: Đang thực hiện
3: Hoàn thành
4: Bảo lưu', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'service_request';

