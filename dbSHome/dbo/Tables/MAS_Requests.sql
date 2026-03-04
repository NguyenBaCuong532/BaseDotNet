CREATE TABLE [dbo].[MAS_Requests] (
    [requestId]      INT              IDENTITY (1, 1) NOT NULL,
    [apartmentId]    INT              NOT NULL,
    [requestKey]     NVARCHAR (50)    NULL,
    [requestDt]      DATETIME         NULL,
    [requestTypeId]  INT              NOT NULL,
    [comment]        NVARCHAR (MAX)   NULL,
    [isNow]          BIT              NULL,
    [atTime]         DATETIME         NULL,
    [status]         INT              NULL,
    [projectCd]      NVARCHAR (30)    NULL,
    [requestUserId]  UNIQUEIDENTIFIER NULL,
    [thread_id]      NVARCHAR (200)   NULL,
    [rating]         INT              NULL,
    [review_dt]      DATETIME         NULL,
    [attachOid]      UNIQUEIDENTIFIER NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Requests_Oid] DEFAULT (newid()) NOT NULL,
    [review_comment] NVARCHAR (250)   NULL,
    [close_dt]       DATETIME         NULL,
    [close_by]       UNIQUEIDENTIFIER NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    [apartOid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_Requests] PRIMARY KEY CLUSTERED ([requestId] ASC),
    CONSTRAINT [FK_MAS_Requests_apartOid] FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments] ([oid]),
    CONSTRAINT [FK_MAS_Requests_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);










GO
CREATE NONCLUSTERED INDEX [idx_MAS_Requests_apartmentId]
    ON [dbo].[MAS_Requests]([apartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Requests_apartOid]
    ON [dbo].[MAS_Requests]([apartOid] ASC);

