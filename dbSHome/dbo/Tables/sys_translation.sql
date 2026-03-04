CREATE TABLE [dbo].[sys_translation] (
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_sys_translation_oid] DEFAULT (newid()) NOT NULL,
    [lang_key]   NVARCHAR (50)    NOT NULL,
    [source]     NVARCHAR (50)    NOT NULL,
    [text]       NVARCHAR (250)   NOT NULL,
    [created_at] DATETIME         NULL,
    [updated_at] DATETIME         NULL,
    CONSTRAINT [PK_sys_translation] PRIMARY KEY CLUSTERED ([oid] ASC, [lang_key] ASC)
);

