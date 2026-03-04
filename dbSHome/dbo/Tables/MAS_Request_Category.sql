CREATE TABLE [dbo].[MAS_Request_Category] (
    [requestCategoryId]      INT              IDENTITY (1, 1) NOT NULL,
    [requestCategoryName]    NVARCHAR (100)   NULL,
    [requestCategoryName_en] NVARCHAR (100)   NULL,
    [code]                   NVARCHAR (20)    NULL,
    [categoryType]           INT              NULL,
    [oid]                    UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Request_Category_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]             UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_RequestCategory] PRIMARY KEY CLUSTERED ([requestCategoryId] ASC),
    CONSTRAINT [FK_MAS_Request_Category_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

