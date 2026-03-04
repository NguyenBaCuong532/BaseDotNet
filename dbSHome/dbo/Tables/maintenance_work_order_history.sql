CREATE TABLE [dbo].[maintenance_work_order_history] (
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_maintenance_work_order_history_oid] DEFAULT (newid()) NOT NULL,
    [work_order_oid] UNIQUEIDENTIFIER NOT NULL,
    [action_type]    NVARCHAR (50)    NOT NULL,
    [old_status]     INT              NULL,
    [new_status]     INT              NULL,
    [notes]          NVARCHAR (MAX)   NULL,
    [action_by]      NVARCHAR (450)   NULL,
    [action_at]      DATETIME         CONSTRAINT [DF_maintenance_work_order_history_action_at] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_maintenance_work_order_history] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_maintenance_work_order_history_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [FK_maintenance_work_order_history_work_order] FOREIGN KEY ([work_order_oid]) REFERENCES [dbo].[maintenance_work_order] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_maintenance_work_order_history_work_order_oid]
    ON [dbo].[maintenance_work_order_history]([work_order_oid] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'History/Audit log table for Work Order status changes and actions', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'maintenance_work_order_history';

