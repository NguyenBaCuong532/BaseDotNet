CREATE TABLE [dbo].[PAR_AppClient] (
    [ClientId]   NVARCHAR (50)    NOT NULL,
    [ClientName] NVARCHAR (100)   NULL,
    [AppId]      INT              NOT NULL,
    [AppName]    NVARCHAR (50)    NULL,
    [CategoryCd] NVARCHAR (50)    NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_PAR_AppClient_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_PAR_AppClient] PRIMARY KEY CLUSTERED ([ClientId] ASC),
    CONSTRAINT [FK_PAR_AppClient_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

