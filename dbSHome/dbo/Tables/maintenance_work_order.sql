CREATE TABLE [dbo].[maintenance_work_order] (
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_maintenance_work_order_oid] DEFAULT (newid()) NOT NULL,
    [site_id]          UNIQUEIDENTIFIER NOT NULL,
    [plan_oid]         UNIQUEIDENTIFIER NULL,
    [wo_code]          NVARCHAR (50)    NOT NULL,
    [title]            NVARCHAR (200)   NOT NULL,
    [description]      NVARCHAR (MAX)   NULL,
    [maintenance_type] NVARCHAR (50)    NULL,
    [priority]         INT              CONSTRAINT [DF_maintenance_work_order_priority] DEFAULT ((2)) NOT NULL,
    [location]         NVARCHAR (200)   NULL,
    [building_cd]      NVARCHAR (50)    NULL,
    [floor]            NVARCHAR (20)    NULL,
    [equipment_oid]    UNIQUEIDENTIFIER NULL,
    [equipment_code]   NVARCHAR (50)    NULL,
    [equipment_model]  NVARCHAR (100)   NULL,
    [assignee_oid]     UNIQUEIDENTIFIER NOT NULL,
    [supervisor_oid]   UNIQUEIDENTIFIER NULL,
    [estimated_hours]  DECIMAL (5, 2)   NULL,
    [start_datetime]   DATETIME         NOT NULL,
    [end_datetime]     DATETIME         NOT NULL,
    [sla_deadline]     DATETIME         NULL,
    [actual_start]     DATETIME         NULL,
    [actual_end]       DATETIME         NULL,
    [status]           INT              CONSTRAINT [DF_maintenance_work_order_status] DEFAULT ((0)) NOT NULL,
    [completion_notes] NVARCHAR (MAX)   NULL,
    [approval_status]  INT              CONSTRAINT [DF_maintenance_work_order_approval_status] DEFAULT ((0)) NOT NULL,
    [approver_oid]     UNIQUEIDENTIFIER NULL,
    [approved_at]      DATETIME         NULL,
    [create_at]        DATETIME         CONSTRAINT [DF_maintenance_work_order_create_at] DEFAULT (getdate()) NOT NULL,
    [create_by]        NVARCHAR (100)   NULL,
    [updated_at]       DATETIME         NULL,
    [updated_by]       NVARCHAR (100)   NULL,
    [is_delete]        BIT              CONSTRAINT [DF_maintenance_work_order_is_delete] DEFAULT ((0)) NOT NULL,
    [rowguid]          UNIQUEIDENTIFIER CONSTRAINT [DF_maintenance_work_order_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_maintenance_work_order] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_maintenance_work_order_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_maintenance_work_order_plan_oid]
    ON [dbo].[maintenance_work_order]([plan_oid] ASC) WHERE ([plan_oid] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_maintenance_work_order_assignee_oid]
    ON [dbo].[maintenance_work_order]([assignee_oid] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_maintenance_work_order_status]
    ON [dbo].[maintenance_work_order]([status] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_maintenance_work_order_wo_code]
    ON [dbo].[maintenance_work_order]([wo_code] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_maintenance_work_order_site_id]
    ON [dbo].[maintenance_work_order]([site_id] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Work Order / Maintenance Ticket table for Maintenance System', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'maintenance_work_order';

