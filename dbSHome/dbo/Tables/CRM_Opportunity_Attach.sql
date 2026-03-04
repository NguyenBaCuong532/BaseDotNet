CREATE TABLE [dbo].[CRM_Opportunity_Attach] (
    [id]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [opp_Id]         BIGINT           NOT NULL,
    [processId]      BIGINT           NULL,
    [attachUrl]      NVARCHAR (455)   NOT NULL,
    [attachType]     NVARCHAR (50)    NULL,
    [attachFileName] NVARCHAR (200)   NULL,
    [createDt]       DATETIME         NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Opportunity_Attach_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_Opportunity_Attach_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

