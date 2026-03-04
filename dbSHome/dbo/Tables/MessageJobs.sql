CREATE TABLE [dbo].[MessageJobs] (
    [messageId]  UNIQUEIDENTIFIER CONSTRAINT [DF_MessageJobs_messageId] DEFAULT (newid()) NOT NULL,
    [phone]      NVARCHAR (150)   NOT NULL,
    [custName]   NVARCHAR (150)   NULL,
    [custId]     NVARCHAR (100)   NULL,
    [contents]   NVARCHAR (400)   NOT NULL,
    [scheduleAt] BIGINT           NULL,
    [brandName]  NVARCHAR (20)    NULL,
    [createId]   NVARCHAR (100)   NULL,
    [createdDt]  DATETIME         NULL,
    [clientId]   NVARCHAR (50)    NULL,
    [clientIp]   NVARCHAR (50)    NULL,
    [sourceId]   UNIQUEIDENTIFIER NULL,
    [remart]     NVARCHAR (200)   NULL,
    [partner]    NVARCHAR (10)    NULL,
    [Schedule]   DATETIME         NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MessageJobs] PRIMARY KEY CLUSTERED ([messageId] ASC),
    CONSTRAINT [FK_MessageJobs_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
CREATE NONCLUSTERED INDEX [idx_MessageJobs_sourceId]
    ON [dbo].[MessageJobs]([sourceId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MessageJobs_custId]
    ON [dbo].[MessageJobs]([custId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Đặt lịch gửi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MessageJobs', @level2type = N'COLUMN', @level2name = N'Schedule';

