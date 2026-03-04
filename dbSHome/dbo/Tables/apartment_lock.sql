CREATE TABLE [dbo].[apartment_lock] (
    [project_cd]     NVARCHAR (50)    NOT NULL,
    [apartment_id]   BIGINT           NOT NULL,
    [device_id]      BIGINT           NOT NULL,
    [lock_name]      NVARCHAR (200)   NULL,
    [door_code]      NVARCHAR (100)   NULL,
    [status]         INT              DEFAULT ((1)) NOT NULL,
    [is_deleted]     BIT              DEFAULT ((0)) NOT NULL,
    [last_unlock_dt] DATETIME2 (0)    NULL,
    [last_unlock_by] NVARCHAR (64)    NULL,
    [created_by]     NVARCHAR (64)    NULL,
    [created_dt]     DATETIME2 (0)    DEFAULT (sysdatetime()) NOT NULL,
    [updated_by]     NVARCHAR (64)    NULL,
    [updated_dt]     DATETIME2 (0)    NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_apartment_lock_oid_guid] DEFAULT (newsequentialid()) NOT NULL,
    CONSTRAINT [PK_apartment_lock_oid] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_apartment_lock_device] FOREIGN KEY ([device_id]) REFERENCES [dbo].[lock_device] ([oid]),
    CONSTRAINT [FK_apartment_lock_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
CREATE NONCLUSTERED INDEX [IX_apartment_lock_project_apartment]
    ON [dbo].[apartment_lock]([project_cd] ASC, [apartment_id] ASC) WHERE ([is_deleted]=(0));


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_apartment_lock_oid]
    ON [dbo].[apartment_lock]([oid] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_apartment_lock_door_code_active]
    ON [dbo].[apartment_lock]([door_code] ASC) WHERE ([is_deleted]=(0));


GO
CREATE NONCLUSTERED INDEX [IX_apartment_lock_project]
    ON [dbo].[apartment_lock]([project_cd] ASC) WHERE ([is_deleted]=(0));


GO
CREATE NONCLUSTERED INDEX [IX_apartment_lock_device]
    ON [dbo].[apartment_lock]([device_id] ASC) WHERE ([is_deleted]=(0));


GO
CREATE NONCLUSTERED INDEX [IX_apartment_lock_apartment]
    ON [dbo].[apartment_lock]([apartment_id] ASC) WHERE ([is_deleted]=(0));

