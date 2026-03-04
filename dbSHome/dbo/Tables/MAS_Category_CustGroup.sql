CREATE TABLE [dbo].[MAS_Category_CustGroup] (
    [groupId]      INT              NOT NULL,
    [categoryCd]   NVARCHAR (20)    NOT NULL,
    [creationTime] DATETIME         CONSTRAINT [DF_MAS_Category_CustGroup_CreationTime] DEFAULT (getdate()) NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Category_CustGroup_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Category_CustGroup] PRIMARY KEY CLUSTERED ([groupId] ASC, [categoryCd] ASC),
    CONSTRAINT [FK_MAS_Category_CustGroup_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

