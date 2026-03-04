CREATE TABLE [dbo].[calendar_event] (
    [oid]             UNIQUEIDENTIFIER NOT NULL,
    [project_cd]      NVARCHAR (30)    NULL,
    [build_cd]        NVARCHAR (30)    NULL,
    [title]           NVARCHAR (250)   NOT NULL,
    [content]         NVARCHAR (MAX)   NULL,
    [location]        NVARCHAR (250)   NULL,
    [start_dt]        DATETIME2 (0)    NOT NULL,
    [end_dt]          DATETIME2 (0)    NULL,
    [is_all_day]      BIT              CONSTRAINT [DF_calendar_event_is_all_day] DEFAULT ((0)) NOT NULL,
    [event_type]      INT              CONSTRAINT [DF_calendar_event_event_type] DEFAULT ((0)) NOT NULL,
    [priority]        INT              CONSTRAINT [DF_calendar_event_priority] DEFAULT ((0)) NOT NULL,
    [status]          INT              CONSTRAINT [DF_calendar_event_status] DEFAULT ((0)) NOT NULL,
    [assignee_userid] NVARCHAR (450)   NULL,
    [remind_min]      INT              NULL,
    [app_st]          INT              CONSTRAINT [DF_calendar_event_app_st] DEFAULT ((1)) NOT NULL,
    [created_at]      DATETIME2 (0)    CONSTRAINT [DF_calendar_event_created_at] DEFAULT (sysutcdatetime()) NOT NULL,
    [created_by]      NVARCHAR (450)   NULL,
    [updated_at]      DATETIME2 (0)    NULL,
    [updated_by]      NVARCHAR (450)   NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_calendar_event] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_calendar_event_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_calendar_event_time]
    ON [dbo].[calendar_event]([start_dt] ASC, [end_dt] ASC, [app_st] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_calendar_event_proj_build]
    ON [dbo].[calendar_event]([project_cd] ASC, [build_cd] ASC, [app_st] ASC);

