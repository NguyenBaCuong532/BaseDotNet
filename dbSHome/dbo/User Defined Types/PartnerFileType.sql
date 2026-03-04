CREATE TYPE [dbo].[PartnerFileType] AS TABLE (
    [file_id]      UNIQUEIDENTIFIER NULL,
    [file_name]    NVARCHAR (255)   NULL,
    [content_type] NVARCHAR (100)   NULL,
    [file_size]    BIGINT           NULL,
    [note]         NVARCHAR (500)   NULL);

