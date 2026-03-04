CREATE TABLE [dbo].[sys_config_data_lang] (
    [id]         BIGINT           NOT NULL,
    [langkey]    NVARCHAR (50)    NOT NULL,
    [par_desc]   NVARCHAR (200)   NULL,
    [created_dt] DATETIME         CONSTRAINT [DF_sys_config_data_lang_created_dt] DEFAULT (getdate()) NOT NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_sys_config_data_lang_oid] DEFAULT (newid()) NOT NULL,
    CONSTRAINT [PK_sys_config_data_lang] PRIMARY KEY CLUSTERED ([id] ASC, [langkey] ASC)
);

