CREATE TABLE [dbo].[CRM_IssueType] (
    [IssueTypeId]   INT              NULL,
    [IssueTypeName] NVARCHAR (100)   NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_IssueType_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_IssueType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

