CREATE TABLE [dbo].[CRM_Issue_Assign] (
    [id]         INT              IDENTITY (1, 1) NOT NULL,
    [issueId]    INT              NOT NULL,
    [userId]     NVARCHAR (100)   NULL,
    [assignRole] INT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Issue_Assign_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_IssueProcess_Assignee] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_CRM_Issue_Assign_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

