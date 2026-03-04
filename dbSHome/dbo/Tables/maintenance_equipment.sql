CREATE TABLE [dbo].[maintenance_equipment] (
    [oid]            UNIQUEIDENTIFIER NOT NULL,
    [equipment_code] NVARCHAR (50)    NOT NULL,
    [equipment_name] NVARCHAR (200)   NOT NULL,
    [building_cd]    NVARCHAR (50)    NULL,
    [floor]          NVARCHAR (50)    NULL,
    [location]       NVARCHAR (200)   NULL,
    [type_cd]        NVARCHAR (50)    NULL,
    [install_date]   DATETIME         NULL,
    [warranty_date]  DATETIME         NULL,
    [manufacturer]   NVARCHAR (200)   NULL,
    [status]         INT              DEFAULT ((0)) NOT NULL,
    [created_by]     UNIQUEIDENTIFIER NULL,
    [created_date]   DATETIME         DEFAULT (getdate()) NULL,
    [modified_by]    UNIQUEIDENTIFIER NULL,
    [modified_date]  DATETIME         NULL,
    [is_deleted]     BIT              DEFAULT ((0)) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_maintenance_equipment] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_maintenance_equipment_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

