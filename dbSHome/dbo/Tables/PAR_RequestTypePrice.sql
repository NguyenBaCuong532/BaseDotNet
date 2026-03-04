CREATE TABLE [dbo].[PAR_RequestTypePrice] (
    [PriceId]       INT              IDENTITY (1, 1) NOT NULL,
    [RequestTypeId] INT              NOT NULL,
    [ItemName]      NVARCHAR (100)   NULL,
    [IsFree]        BIT              NULL,
    [Price]         DECIMAL (18)     NULL,
    [Unit]          NVARCHAR (50)    NULL,
    [Note]          NVARCHAR (200)   NULL,
    [Post]          INT              NULL,
    [isUsed]        BIT              NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_PAR_RequestTypePrice_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_RequestTypePrice] PRIMARY KEY CLUSTERED ([PriceId] ASC),
    CONSTRAINT [FK_PAR_RequestTypePrice_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

