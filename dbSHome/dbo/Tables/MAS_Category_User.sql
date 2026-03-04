CREATE TABLE [dbo].[MAS_Category_User] (
    [userId]       NVARCHAR (100)   NOT NULL,
    [base_type]    INT              CONSTRAINT [DF_MAS_Category_User_base_type] DEFAULT ((0)) NOT NULL,
    [categoryCd]   NVARCHAR (50)    NOT NULL,
    [isAll]        BIT              CONSTRAINT [DF_MAS_Category_User_isAll] DEFAULT ((0)) NULL,
    [creationTime] DATETIME         CONSTRAINT [DF_MAS_Category_User_CreationTime] DEFAULT (getdate()) NULL,
    [webId]        NVARCHAR (100)   NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Category_User_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_MAS_Category_User_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_MAS_Category_User_webId]
    ON [dbo].[MAS_Category_User]([webId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Category_User_categoryCd]
    ON [dbo].[MAS_Category_User]([categoryCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Category_User_userId]
    ON [dbo].[MAS_Category_User]([userId] ASC);

