CREATE TABLE [dbo].[sys_config_message_lang] (
    [id]         BIGINT           NOT NULL,
    [langkey]    NVARCHAR (50)    NOT NULL,
    [messages]   NVARCHAR (250)   NULL,
    [created_dt] DATETIME         CONSTRAINT [DF_sys_config_message_created_dt] DEFAULT (getdate()) NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_sys_config_message_lang_oid] DEFAULT (newid()) NOT NULL,
    CONSTRAINT [PK_sys_config_message_lang] PRIMARY KEY CLUSTERED ([id] ASC, [langkey] ASC)
);

