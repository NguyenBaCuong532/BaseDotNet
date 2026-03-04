CREATE TABLE [dbo].[service_package_lang] (
    [id]      UNIQUEIDENTIFIER NOT NULL,
    [langkey] NVARCHAR (10)    NOT NULL,
    [name]    NVARCHAR (250)   NULL,
    CONSTRAINT [PK_service_package_lang] PRIMARY KEY CLUSTERED ([id] ASC, [langkey] ASC),
    CONSTRAINT [FK_service_package_lang_service_package] FOREIGN KEY ([id]) REFERENCES [dbo].[service_package] ([id]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_service_package_lang_langkey]
    ON [dbo].[service_package_lang]([langkey] ASC);

