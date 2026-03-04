CREATE TABLE [dbo].[WAL_ProviderType] (
    [ProviderTypeId]   INT              NOT NULL,
    [ProviderTypeName] NVARCHAR (50)    NOT NULL,
    [SysDate]          DATETIME         CONSTRAINT [DF_WAL_ProviderType_SysDate] DEFAULT (getdate()) NOT NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_ProviderType_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_ProviderType] PRIMARY KEY CLUSTERED ([ProviderTypeId] ASC),
    CONSTRAINT [FK_WAL_ProviderType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

