CREATE TABLE [dbo].[UserProject] (
    [id]               UNIQUEIDENTIFIER CONSTRAINT [DF_UserProject_id] DEFAULT (newid()) NOT NULL,
    [projectCd]        NVARCHAR (50)    NOT NULL,
    [userId]           NVARCHAR (100)   NOT NULL,
    [created]          DATETIME         CONSTRAINT [DF_UserProject_created] DEFAULT (getdate()) NOT NULL,
    [created_by]       NVARCHAR (100)   NULL,
    [updated]          DATETIME         NULL,
    [updated_by]       NVARCHAR (100)   NULL,
    [createdDate]      DATETIME         NULL,
    [LastModifiedBy]   NVARCHAR (250)   NULL,
    [LastModifiedDate] DATETIME         NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_UserProject] PRIMARY KEY CLUSTERED ([projectCd] ASC, [userId] ASC),
    CONSTRAINT [FK_UserProject_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

