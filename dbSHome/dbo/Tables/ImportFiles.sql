CREATE TABLE [dbo].[ImportFiles] (
    [impId]            UNIQUEIDENTIFIER CONSTRAINT [DF_ImportFiles_impId] DEFAULT (newid()) NOT NULL,
    [import_type]      NVARCHAR (50)    NULL,
    [upload_file_name] NVARCHAR (150)   NULL,
    [upload_file_type] NVARCHAR (100)   NULL,
    [upload_file_url]  NVARCHAR (450)   NULL,
    [upload_file_size] INT              NULL,
    [tempId]           UNIQUEIDENTIFIER NULL,
    [row_count]        INT              NULL,
    [row_new]          INT              NULL,
    [row_update]       INT              NULL,
    [row_fail]         INT              NULL,
    [created_by]       NVARCHAR (100)   NULL,
    [created_dt]       DATETIME         CONSTRAINT [DF_ImportFiles_created_dt] DEFAULT (getdate()) NOT NULL,
    [updated_st]       INT              NULL,
    [updated_by]       NVARCHAR (100)   NULL,
    [updated_dt]       DATETIME         NULL,
    [projectCd]        NVARCHAR (10)    NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ImportFiles] PRIMARY KEY CLUSTERED ([impId] ASC),
    CONSTRAINT [FK_ImportFiles_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

