CREATE TABLE [dbo].[module_app_lang] (
    [mod_cd]     NVARCHAR (50)    NOT NULL,
    [mod_name]   NVARCHAR (250)   NOT NULL,
    [mod_title]  NVARCHAR (150)   NULL,
    [langKey]    VARCHAR (5)      NOT NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_module_app_lang_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_module_app_lang] PRIMARY KEY CLUSTERED ([mod_cd] ASC, [langKey] ASC),
    CONSTRAINT [FK_module_app_lang_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

