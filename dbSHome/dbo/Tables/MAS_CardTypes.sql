CREATE TABLE [dbo].[MAS_CardTypes] (
    [CardTypeId]     INT              IDENTITY (1, 1) NOT NULL,
    [CardTypeName]   NVARCHAR (100)   NULL,
    [CardTypeNameEn] NVARCHAR (100)   NULL,
    [Post]           INT              NULL,
    [CardTypeImg]    NVARCHAR (350)   NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardTypes_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CardTypes] PRIMARY KEY CLUSTERED ([CardTypeId] ASC),
    CONSTRAINT [FK_MAS_CardTypes_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

