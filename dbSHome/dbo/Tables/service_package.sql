CREATE TABLE [dbo].[service_package] (
    [id]             UNIQUEIDENTIFIER CONSTRAINT [DF_service_package_id] DEFAULT (newid()) NOT NULL,
    [service_id]     UNIQUEIDENTIFIER NULL,
    [name]           NVARCHAR (250)   NOT NULL,
    [price]          DECIMAL (18)     NULL,
    [estimated_time] DECIMAL (18, 1)  NULL,
    [has_extra]      BIT              NULL,
    [is_extra]       BIT              NULL,
    [ordinal]        INT              NULL,
    [is_active]      BIT              NULL,
    [created_dt]     DATETIME         CONSTRAINT [DF_service_package_created_dt] DEFAULT (getdate()) NULL,
    [created_by]     UNIQUEIDENTIFIER NULL,
    [updated_dt]     DATETIME         NULL,
    [updated_by]     UNIQUEIDENTIFIER NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_service_package] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_service_package_service] FOREIGN KEY ([service_id]) REFERENCES [dbo].[service] ([id]),
    CONSTRAINT [FK_service_package_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

