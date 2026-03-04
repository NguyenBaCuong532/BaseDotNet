CREATE TABLE [dbo].[service_lang] (
    [id]          UNIQUEIDENTIFIER NOT NULL,
    [langkey]     NVARCHAR (10)    NOT NULL,
    [name]        NVARCHAR (250)   NULL,
    [description] NVARCHAR (250)   NULL,
    CONSTRAINT [PK_service_lang] PRIMARY KEY CLUSTERED ([id] ASC, [langkey] ASC),
    CONSTRAINT [FK_service_lang_service] FOREIGN KEY ([id]) REFERENCES [dbo].[service] ([id]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_service_lang_langkey]
    ON [dbo].[service_lang]([langkey] ASC);

