CREATE TYPE [dbo].[user_notify_to] AS TABLE (
    [id]        UNIQUEIDENTIFIER NULL,
    [to_level]  INT              NOT NULL,
    [to_groups] NVARCHAR (MAX)   NULL,
    [to_row]    INT              NULL,
    [to_type]   INT              NULL);

