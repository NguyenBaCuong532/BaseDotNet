CREATE TYPE [dbo].[RequestAttachmentType] AS TABLE (
    [Id]             BIGINT         NULL,
    [RequestId]      BIGINT         NULL,
    [ProcessId]      BIGINT         NULL,
    [AttachUrl]      NVARCHAR (450) NULL,
    [AttachType]     NVARCHAR (50)  NULL,
    [AttachFileName] NVARCHAR (200) NULL,
    [Used]           BIT            NULL);

