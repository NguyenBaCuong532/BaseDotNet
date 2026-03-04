CREATE TABLE [dbo].[CRM_Opportunity_Assign] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [opp_Id]     BIGINT           NOT NULL,
    [userId]     NVARCHAR (50)    NOT NULL,
    [assignRole] INT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Opportunity_Assign_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Opportunity_Assign] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_CRM_Opportunity_Assign_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

