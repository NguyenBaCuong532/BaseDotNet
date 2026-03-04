CREATE TABLE [dbo].[MAS_CardPartnerFile] (
    [partner_file_id] INT              IDENTITY (1, 1) NOT NULL,
    [partner_id]      INT              NOT NULL,
    [file_id]         UNIQUEIDENTIFIER NOT NULL,
    [file_name]       NVARCHAR (255)   NULL,
    [content_type]    NVARCHAR (100)   NULL,
    [file_size]       BIGINT           NULL,
    [note]            NVARCHAR (200)   NULL,
    [create_dt]       DATETIME         NULL,
    [create_by]       UNIQUEIDENTIFIER NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([partner_file_id] ASC),
    CONSTRAINT [FK_MAS_CardPartnerFile_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_CardPartnerFile_partner]
    ON [dbo].[MAS_CardPartnerFile]([partner_id] ASC);

