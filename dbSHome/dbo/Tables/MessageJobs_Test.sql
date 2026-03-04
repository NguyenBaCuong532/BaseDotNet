CREATE TABLE [dbo].[MessageJobs_Test] (
    [messageId]  UNIQUEIDENTIFIER CONSTRAINT [DF_MessageJobs_Test_messageId] DEFAULT (newid()) NOT NULL,
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
    [partner]    NVARCHAR (100)   NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MessageJobs_Test_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MessageJobs_Test] PRIMARY KEY CLUSTERED ([messageId] ASC),
    CONSTRAINT [FK_MessageJobs_Test_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

