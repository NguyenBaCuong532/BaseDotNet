CREATE TABLE [dbo].[WAL_Service_Provider] (
    [ServiceKey] NVARCHAR (16)    NOT NULL,
    [ProviderId] INT              NOT NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_Service_Provider_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_Service_Provider] PRIMARY KEY CLUSTERED ([ServiceKey] ASC, [ProviderId] ASC),
    CONSTRAINT [FK_WAL_Service_Provider_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

