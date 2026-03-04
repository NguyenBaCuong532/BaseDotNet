CREATE TABLE [dbo].[sys_config_form_log] (
    [id]          BIGINT           NOT NULL,
    [userId]      UNIQUEIDENTIFIER NOT NULL,
    [columnValue] NVARCHAR (500)   NULL,
    [created_dt]  DATETIME         CONSTRAINT [DF_sys_config_form_log_created_dt] DEFAULT (getdate()) NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_sys_config_form_log_oid] DEFAULT (newid()) NOT NULL,
    CONSTRAINT [PK_sys_config_form_log] PRIMARY KEY CLUSTERED ([id] ASC, [userId] ASC)
);

