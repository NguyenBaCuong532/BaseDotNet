CREATE TABLE [dbo].[sys_config_form_lang] (
    [id]          BIGINT           NOT NULL,
    [langkey]     NVARCHAR (50)    NOT NULL,
    [columnLabel] NVARCHAR (160)   NULL,
    [created_dt]  DATETIME         CONSTRAINT [DF_sys_config_form_lang_created_dt] DEFAULT (getdate()) NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_sys_config_form_lang_oid] DEFAULT (newid()) NOT NULL,
    CONSTRAINT [PK_sys_config_form_lang] PRIMARY KEY CLUSTERED ([id] ASC, [langkey] ASC)
);

