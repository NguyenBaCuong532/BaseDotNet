CREATE TABLE [dbo].[maintenance_plan_history] (
    [oid]         UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [plan_oid]    UNIQUEIDENTIFIER NOT NULL,
    [action_type] VARCHAR (50)     NOT NULL,
    [old_status]  INT              NULL,
    [new_status]  INT              NULL,
    [notes]       NVARCHAR (MAX)   NULL,
    [action_by]   NVARCHAR (450)   NULL,
    [action_at]   DATETIME         DEFAULT (getdate()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_maintenance_plan_history] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_maintenance_plan_history_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

