CREATE TABLE [dbo].[CRM_Issues] (
    [issueId]       BIGINT           IDENTITY (1, 1) NOT NULL,
    [custId]        NVARCHAR (50)    NOT NULL,
    [projectCd]     NVARCHAR (50)    NULL,
    [issueType]     INT              NULL,
    [summary]       NVARCHAR (200)   NULL,
    [description]   NVARCHAR (500)   NULL,
    [securityLevel] INT              NULL,
    [createBy]      NVARCHAR (50)    NULL,
    [createDt]      DATETIME         NULL,
    [subStatus]     INT              NULL,
    [priority]      INT              NULL,
    [serverity]     INT              NULL,
    [assignee]      NVARCHAR (50)    NULL,
    [reporterTo]    NVARCHAR (50)    NULL,
    [startDt]       DATETIME         NULL,
    [dueDt]         DATETIME         NULL,
    [dueCustDt]     DATETIME         NULL,
    [subType]       INT              NULL,
    [requestor]     NVARCHAR (100)   NULL,
    [impart]        NVARCHAR (300)   NULL,
    [feedback]      NVARCHAR (200)   NULL,
    [causeIssue]    NVARCHAR (200)   NULL,
    [cPAction]      NVARCHAR (200)   NULL,
    [issueLevel]    NVARCHAR (150)   NULL,
    [solution]      NVARCHAR (150)   NULL,
    [issue_st]      INT              NULL,
    [thread_id]     NVARCHAR (200)   NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Issues_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_Issues_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_CRM_Issues_custId]
    ON [dbo].[CRM_Issues]([custId] ASC);

