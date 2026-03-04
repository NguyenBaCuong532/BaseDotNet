CREATE TABLE [dbo].[support_request_assignments] (
    [oid]                UNIQUEIDENTIFIER NOT NULL,
    [support_request_id] UNIQUEIDENTIFIER NOT NULL,
    [assigned_user_id]   UNIQUEIDENTIFIER NOT NULL,
    [is_active]          BIT              CONSTRAINT [DF_par_support_request_assignments_is_active] DEFAULT ((1)) NOT NULL,
    [note]               NVARCHAR (500)   NULL,
    [created_by]         UNIQUEIDENTIFIER NOT NULL,
    [created_at]         DATETIME         CONSTRAINT [DF_support_request_assignments_created_at] DEFAULT (getdate()) NOT NULL,
    [updated_by]         UNIQUEIDENTIFIER NOT NULL,
    [updated_at]         DATETIME         CONSTRAINT [DF_support_request_assignments_updated_at] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_par_support_request_assignments] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_support_request_assignments_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Đánh dấu nhân viên này có đang xử lý hay không, nếu không thì được coi là lịch sử (NV này đã từng được gán xử lý công việc này)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'support_request_assignments', @level2type = N'COLUMN', @level2name = N'is_active';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Quản lý phân công công việc, mỗi yêu cầu sẽ gắn với 1 hoặc nhiều nhân viên cùng phụ trách đồng thời để lưu lại lịch sử phân công công việc', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'support_request_assignments';

