CREATE TYPE [dbo].[NotifySentImportType] AS TABLE (
    [STT]      INT            NULL,
    [FullName] NVARCHAR (250) NULL,
    [Phone]    NVARCHAR (100) NULL,
    [Email]    NVARCHAR (200) NULL,
    [Room]     NVARCHAR (50)  NULL,
    [Errors]   NVARCHAR (500) NULL);

