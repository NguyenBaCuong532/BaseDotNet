CREATE TABLE [dbo].[lock_device] (
    [oid]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [project_cd]  NVARCHAR (50)    NOT NULL,
    [device_code] NVARCHAR (100)   NOT NULL,
    [vendor]      NVARCHAR (100)   NULL,
    [model]       NVARCHAR (100)   NULL,
    [status]      INT              DEFAULT ((1)) NOT NULL,
    [is_deleted]  BIT              DEFAULT ((0)) NOT NULL,
    [created_by]  NVARCHAR (64)    NULL,
    [created_dt]  DATETIME2 (0)    DEFAULT (sysdatetime()) NOT NULL,
    [updated_by]  NVARCHAR (64)    NULL,
    [updated_dt]  DATETIME2 (0)    NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_lock_device_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_lock_device_project_code]
    ON [dbo].[lock_device]([project_cd] ASC, [device_code] ASC) WHERE ([is_deleted]=(0));

