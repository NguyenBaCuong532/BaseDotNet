CREATE TABLE [dbo].[par_project_config_default] (
    [oid]                  UNIQUEIDENTIFIER CONSTRAINT [DF_par_project_config_default_oid] DEFAULT (newid()) NOT NULL,
    [config_code]          NVARCHAR (50)    NOT NULL,
    [config_name]          NVARCHAR (100)   NOT NULL,
    [config_type]          NVARCHAR (50)    NOT NULL,
    [config_value_default] NVARCHAR (500)   NOT NULL,
    [tenant_oid]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_par_project_config_default] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_project_config_default_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

