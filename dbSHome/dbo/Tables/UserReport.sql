CREATE TABLE [dbo].[UserReport] (
    [webId]      UNIQUEIDENTIFIER NOT NULL,
    [userId]     UNIQUEIDENTIFIER NOT NULL,
    [reportId]   UNIQUEIDENTIFIER NOT NULL,
    [created]    DATETIME         NULL,
    [created_by] UNIQUEIDENTIFIER NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_UserReport_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_UserReport_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

