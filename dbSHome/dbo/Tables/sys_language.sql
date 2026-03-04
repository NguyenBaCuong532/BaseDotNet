CREATE TABLE [dbo].[sys_language] (
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_sys_language_oid] DEFAULT (newid()) NOT NULL,
    [code]       NVARCHAR (50)    NOT NULL,
    [name]       NVARCHAR (100)   NOT NULL,
    [ordinal]    INT              NULL,
    [created_at] DATETIME         CONSTRAINT [DF_sys_language_created_at] DEFAULT (getdate()) NULL,
    [updated_at] DATETIME         NULL,
    CONSTRAINT [PK_sys_language] PRIMARY KEY CLUSTERED ([oid] ASC)
);

