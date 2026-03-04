CREATE TABLE [dbo].[MAS_Request_Types] (
    [requestTypeId]      INT              IDENTITY (1, 1) NOT NULL,
    [requestTypeName]    NVARCHAR (100)   NULL,
    [requestTypeName_en] NVARCHAR (100)   NULL,
    [requestCategoryId]  INT              NULL,
    [category]           NVARCHAR (20)    NULL,
    [isFree]             BIT              NULL,
    [price]              DECIMAL (18)     NULL,
    [unit]               NVARCHAR (50)    NULL,
    [note]               NVARCHAR (200)   NULL,
    [typeName]           NVARCHAR (50)    NULL,
    [isReady]            BIT              NULL,
    [iconUrl]            NVARCHAR (450)   NULL,
    [sub_prod_cd]        NVARCHAR (50)    NULL,
    [chat_cd]            NVARCHAR (50)    NULL,
    [oid]                UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Request_Types_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_RequestTypes] PRIMARY KEY CLUSTERED ([requestTypeId] ASC),
    CONSTRAINT [FK_MAS_Request_Types_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

