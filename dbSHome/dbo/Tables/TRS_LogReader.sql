CREATE TABLE [dbo].[TRS_LogReader] (
    [LogId]      INT              IDENTITY (1, 1) NOT NULL,
    [StationId]  INT              NOT NULL,
    [CardId]     INT              NOT NULL,
    [LogDt]      DATETIME         NOT NULL,
    [UserId]     NVARCHAR (50)    NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_LogReader_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    [cardOid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_LogReader] PRIMARY KEY CLUSTERED ([LogId] ASC),
    CONSTRAINT [FK_TRS_LogReader_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [IX_TRS_LogReader_LogDt_CardId]
    ON [dbo].[TRS_LogReader]([LogDt] DESC, [CardId] ASC)
    INCLUDE([LogId], [StationId]);

