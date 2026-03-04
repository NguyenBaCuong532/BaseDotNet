CREATE TABLE [dbo].[CRM_Attend_Category] (
    [attend_cd]      NVARCHAR (20)    NOT NULL,
    [attend_name]    NVARCHAR (250)   NOT NULL,
    [attend_desc]    NVARCHAR (500)   NOT NULL,
    [reply_subject]  NVARCHAR (250)   NULL,
    [reply_contents] NVARCHAR (MAX)   NULL,
    [reply_footer]   NVARCHAR (500)   NULL,
    [reply_by]       NVARCHAR (200)   NULL,
    [reply_bodytype] NVARCHAR (50)    NULL,
    [cc_subject]     NVARCHAR (200)   NULL,
    [cc_mails]       NVARCHAR (500)   NULL,
    [cc_contents]    NVARCHAR (MAX)   NULL,
    [sys_date]       DATETIME         NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Attend_Category_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Attend_Category] PRIMARY KEY CLUSTERED ([attend_cd] ASC),
    CONSTRAINT [FK_CRM_Attend_Category_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

