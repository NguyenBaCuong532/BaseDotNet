CREATE TABLE [dbo].[UserSubProject] (
    [id]               UNIQUEIDENTIFIER CONSTRAINT [DF_UserSubProject_id] DEFAULT (newid()) NOT NULL,
    [subProjectCd]     NVARCHAR (50)    NOT NULL,
    [userId]           UNIQUEIDENTIFIER NOT NULL,
    [created]          DATETIME         NOT NULL,
    [created_by]       NVARCHAR (100)   NULL,
    [updated]          DATETIME         NULL,
    [updated_by]       NVARCHAR (100)   NULL,
    [createdDate]      DATETIME         NULL,
    [LastModifiedBy]   NVARCHAR (250)   NULL,
    [LastModifiedDate] DATETIME         NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_UserSubProject] PRIMARY KEY CLUSTERED ([subProjectCd] ASC, [userId] ASC),
    CONSTRAINT [FK_UserSubProject_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

