CREATE TABLE [dbo].[CRM_Opportunity_Process] (
    [processId]  INT              IDENTITY (1, 1) NOT NULL,
    [opp_Id]     INT              NOT NULL,
    [comment]    NVARCHAR (400)   NULL,
    [processDt]  DATETIME         NULL,
    [userId]     NVARCHAR (50)    NOT NULL,
    [assignRole] INT              NULL,
    [statusId]   INT              NULL,
    [approve_st] BIT              NULL,
    [approve_dt] DATETIME         NULL,
    [approve_by] NVARCHAR (50)    NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Opportunity_Process_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Opportunity_Process] PRIMARY KEY CLUSTERED ([processId] ASC),
    CONSTRAINT [FK_CRM_Opportunity_Process_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

