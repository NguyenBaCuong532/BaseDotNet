CREATE TABLE [dbo].[CRM_Issue_Attach] (
    [id]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [issueId]        BIGINT           NOT NULL,
    [processId]      BIGINT           NULL,
    [attachUrl]      NVARCHAR (455)   NULL,
    [createDt]       DATETIME         NULL,
    [attachType]     NVARCHAR (50)    NULL,
    [attachFileName] NVARCHAR (250)   NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Issue_Attach_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_Issue_Attach_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

