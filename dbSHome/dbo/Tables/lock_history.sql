CREATE TABLE [dbo].[lock_history] (
    [oid]          BIGINT           IDENTITY (1, 1) NOT NULL,
    [project_cd]   NVARCHAR (50)    NOT NULL,
    [apartment_id] BIGINT           NULL,
    [action_type]  NVARCHAR (50)    NOT NULL,
    [action_by]    NVARCHAR (64)    NULL,
    [action_dt]    DATETIME2 (0)    DEFAULT (sysdatetime()) NOT NULL,
    [result_code]  INT              DEFAULT ((1)) NOT NULL,
    [message]      NVARCHAR (500)   NULL,
    [client_id]    NVARCHAR (64)    NULL,
    [request_id]   NVARCHAR (64)    NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    [lock_id]      UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_lock_history_lock] FOREIGN KEY ([lock_id]) REFERENCES [dbo].[apartment_lock] ([oid]),
    CONSTRAINT [FK_lock_history_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
CREATE NONCLUSTERED INDEX [IX_lock_history_project_lock_dt]
    ON [dbo].[lock_history]([project_cd] ASC, [lock_id] ASC, [action_dt] DESC)
    INCLUDE([apartment_id], [action_type], [action_by], [result_code], [client_id]);

