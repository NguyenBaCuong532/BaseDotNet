CREATE TYPE [dbo].[user_notify_attach] AS TABLE (
    [n_id]        UNIQUEIDENTIFIER NULL,
    [attach_name] NVARCHAR (200)   NULL,
    [attach_url]  NVARCHAR (MAX)   NOT NULL,
    [attach_type] NVARCHAR (100)   NULL,
    [attach_size] INT              NULL);

