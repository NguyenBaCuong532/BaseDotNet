CREATE TABLE [dbo].[CRM_Notes] (
    [Id]         VARCHAR (150)    NOT NULL,
    [UserId]     VARCHAR (150)    NOT NULL,
    [Custid]     VARCHAR (150)    NOT NULL,
    [Contents]   NVARCHAR (1000)  NULL,
    [Created]    DATETIME         NULL,
    [Updated]    DATETIME         NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Notes_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_Notes_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

