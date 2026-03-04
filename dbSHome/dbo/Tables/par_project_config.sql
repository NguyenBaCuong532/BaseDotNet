CREATE TABLE [dbo].[par_project_config] (
    [oid]                  UNIQUEIDENTIFIER CONSTRAINT [DF_par_project_config_oid] DEFAULT (newid()) NOT NULL,
    [project_code]         NCHAR (10)       NOT NULL,
    [config_code]          NVARCHAR (50)    NOT NULL,
    [config_name]          NVARCHAR (100)   NOT NULL,
    [config_value]         NVARCHAR (500)   NULL,
    [config_value_default] NVARCHAR (500)   NOT NULL,
    [config_type]          NVARCHAR (50)    NOT NULL,
    [created_by]           UNIQUEIDENTIFIER NOT NULL,
    [created_date]         DATETIME         CONSTRAINT [DF_par_project_config_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]     UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date]   DATETIME         CONSTRAINT [DF_par_project_config_last_modified_date] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_par_project_config] PRIMARY KEY CLUSTERED ([oid] ASC)
);

