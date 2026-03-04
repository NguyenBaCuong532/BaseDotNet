CREATE TABLE [dbo].[CRM_Group] (
    [GroupId]     INT              IDENTITY (1, 1) NOT NULL,
    [HiddenName]  NVARCHAR (255)   NULL,
    [GroupName]   NVARCHAR (255)   NULL,
    [ParentId]    INT              NULL,
    [IsActive]    BIT              CONSTRAINT [DF_CRM_Group_IsActive] DEFAULT ((1)) NOT NULL,
    [GroupMail]   NVARCHAR (255)   NULL,
    [GroupLevel]  INT              NULL,
    [CreatedBy]   NVARCHAR (50)    NULL,
    [CreatedTime] DATETIME         NULL,
    [UpdatedBy]   NVARCHAR (50)    NULL,
    [UpdatedTime] DATETIME         NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Group_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_Group_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1: active, 0: inactive', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CRM_Group', @level2type = N'COLUMN', @level2name = N'IsActive';

