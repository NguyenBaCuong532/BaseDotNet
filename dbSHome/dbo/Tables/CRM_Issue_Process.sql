CREATE TABLE [dbo].[CRM_Issue_Process] (
    [processId]  INT              IDENTITY (1, 1) NOT NULL,
    [issueId]    INT              NOT NULL,
    [comment]    NVARCHAR (400)   NULL,
    [processDt]  DATETIME         NULL,
    [custId]     NVARCHAR (50)    NULL,
    [userId]     NVARCHAR (50)    NULL,
    [assignRole] INT              NULL,
    [statusId]   INT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Issue_Process_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_IssueProcess] PRIMARY KEY CLUSTERED ([processId] ASC),
    CONSTRAINT [FK_CRM_Issue_Process_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

