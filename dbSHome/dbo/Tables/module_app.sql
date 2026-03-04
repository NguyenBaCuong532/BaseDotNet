CREATE TABLE [dbo].[module_app] (
    [mod_cd]     NVARCHAR (16)    NOT NULL,
    [mod_name]   NVARCHAR (50)    NOT NULL,
    [mod_title]  NVARCHAR (150)   NULL,
    [mod_icon]   NVARCHAR (150)   NULL,
    [on_flg]     BIT              NULL,
    [mod_gr]     INT              NULL,
    [parent_cd]  NVARCHAR (16)    NULL,
    [int_ord]    INT              NULL,
    [icon_type]  INT              NULL,
    [created_at] DATETIME         NULL,
    [pathMobile] NVARCHAR (50)    NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_module_app_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_module_app] PRIMARY KEY CLUSTERED ([mod_cd] ASC),
    CONSTRAINT [FK_module_app_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

