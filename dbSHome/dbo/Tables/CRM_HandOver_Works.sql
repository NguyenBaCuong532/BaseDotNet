CREATE TABLE [dbo].[CRM_HandOver_Works] (
    [WorkHandOverDtId] BIGINT           IDENTITY (1, 1) NOT NULL,
    [TitleWorkHanOver] NVARCHAR (200)   NULL,
    [WorkStatusId]     INT              NULL,
    [StartDate]        DATETIME         NULL,
    [EndDate]          DATETIME         NULL,
    [TotalTime]        DATETIME         NULL,
    [AssignUser]       NVARCHAR (500)   NULL,
    [AssignAdmin]      NVARCHAR (50)    NULL,
    [Created]          DATETIME         NULL,
    [CreatedBy]        NVARCHAR (50)    NULL,
    [Modified]         DATETIME         NULL,
    [ModifiedBy]       NVARCHAR (50)    NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_HandOver_Works_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_HandOver_Works] PRIMARY KEY CLUSTERED ([WorkHandOverDtId] ASC),
    CONSTRAINT [FK_CRM_HandOver_Works_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

