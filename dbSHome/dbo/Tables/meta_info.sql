CREATE TABLE [dbo].[meta_info] (
    [Oid]         UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [sourceOid]   UNIQUEIDENTIFIER NOT NULL,
    [source_type] NVARCHAR (50)    NULL,
    [meta_title]  NVARCHAR (200)   NULL,
    [meta_note]   NVARCHAR (400)   NULL,
    [meta_type]   INT              NULL,
    [file_name]   NVARCHAR (200)   NULL,
    [file_size]   INT              NULL,
    [file_url]    NVARCHAR (500)   NULL,
    [created]     DATETIME         DEFAULT (getdate()) NULL,
    [created_by]  NVARCHAR (50)    NULL,
    [updated]     DATETIME         NULL,
    [updated_by]  NVARCHAR (50)    NULL,
    [file_type]   NVARCHAR (100)   NULL,
    [objectName]  NVARCHAR (250)   NULL,
    [bucket]      NVARCHAR (250)   NULL,
    [typeOid]     UNIQUEIDENTIFIER NULL,
    [path_temple] NVARCHAR (250)   NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_meta_info] PRIMARY KEY CLUSTERED ([Oid] ASC),
    CONSTRAINT [FK_meta_info_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

