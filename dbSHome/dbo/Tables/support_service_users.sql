CREATE TABLE [dbo].[support_service_users] (
    [oid]                 UNIQUEIDENTIFIER NOT NULL,
    [support_service_oid] UNIQUEIDENTIFIER NOT NULL,
    [user_oid]            UNIQUEIDENTIFIER NOT NULL,
    [service_role]        NVARCHAR (50)    NOT NULL,
    [is_active]           BIT              CONSTRAINT [DF_par_support_service_users_is_active] DEFAULT ((1)) NOT NULL,
    [created_by]          UNIQUEIDENTIFIER NOT NULL,
    [created_at]          DATETIME         CONSTRAINT [DF_support_service_users_created_at] DEFAULT (getdate()) NOT NULL,
    [updated_by]          UNIQUEIDENTIFIER NOT NULL,
    [updated_at]          DATETIME         CONSTRAINT [DF_support_service_users_updated_at] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_support_service_users] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_support_service_users_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Phân công quản lý, nhân viên phụ trách từng loại yêu cầu hỗ trơ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'support_service_users';

