CREATE TABLE [dbo].[MAS_Category] (
    [categoryCd]    NVARCHAR (50)    NOT NULL,
    [base_type]     INT              NOT NULL,
    [categoryName]  NVARCHAR (200)   NULL,
    [showName]      NVARCHAR (200)   NULL,
    [categoryLevel] INT              NULL,
    [categoryMail]  NVARCHAR (255)   NULL,
    [parentCd]      NVARCHAR (20)    NULL,
    [createdBy]     NVARCHAR (50)    NULL,
    [createdTime]   DATETIME         NULL,
    [isActive]      BIT              CONSTRAINT [DF_MAS_Customer_Category_IsActive] DEFAULT ((1)) NOT NULL,
    [intOrder]      INT              NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Category_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Customer_Category] PRIMARY KEY CLUSTERED ([categoryCd] ASC, [base_type] ASC),
    CONSTRAINT [FK_MAS_Category_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

