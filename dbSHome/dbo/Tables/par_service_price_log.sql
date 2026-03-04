CREATE TABLE [dbo].[par_service_price_log] (
    [oid]                UNIQUEIDENTIFIER CONSTRAINT [DF_par_service_price_log_oid] DEFAULT (newid()) NOT NULL,
    [project_code]       NVARCHAR (50)    NOT NULL,
    [table_name]         NVARCHAR (100)   NOT NULL,
    [object_id]          UNIQUEIDENTIFIER NOT NULL,
    [actions]            NVARCHAR (50)    NOT NULL,
    [json_content]       NVARCHAR (MAX)   NOT NULL,
    [created_user]       UNIQUEIDENTIFIER NOT NULL,
    [created_date]       DATETIME         CONSTRAINT [DF_par_service_price_log_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]   UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date] DATETIME         CONSTRAINT [DF_par_service_price_log_last_modified_date] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_par_service_price_log] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_service_price_log_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

