CREATE TABLE [dbo].[MAS_Category_Customer] (
    [custId]       NVARCHAR (50)    NOT NULL,
    [categoryCd]   NVARCHAR (50)    NOT NULL,
    [creationTime] DATETIME         CONSTRAINT [DF_MAS_Category_Customer_CreationTime] DEFAULT (getdate()) NULL,
    [userId]       NVARCHAR (100)   NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Category_Customer_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Category_Customer] PRIMARY KEY CLUSTERED ([custId] ASC, [categoryCd] ASC),
    CONSTRAINT [FK_MAS_Category_Customer_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_MAS_Category_Customer_userId]
    ON [dbo].[MAS_Category_Customer]([userId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Category_Customer_CategoryCd]
    ON [dbo].[MAS_Category_Customer]([categoryCd] ASC);

