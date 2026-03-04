CREATE TABLE [dbo].[WAL_Providers] (
    [ProviderId]     INT              IDENTITY (1, 1) NOT NULL,
    [ProviderCd]     NVARCHAR (50)    NOT NULL,
    [ProviderTypeId] INT              NULL,
    [ProviderShort]  NVARCHAR (100)   NOT NULL,
    [ProviderName]   NVARCHAR (200)   NOT NULL,
    [Address]        NVARCHAR (300)   NULL,
    [LogoUrl]        NVARCHAR (250)   NULL,
    [ContactName]    NVARCHAR (100)   NULL,
    [Phone]          NVARCHAR (30)    NULL,
    [Email]          NVARCHAR (150)   NULL,
    [CreateDt]       DATETIME         CONSTRAINT [DF_Wal_Providers_SysDate] DEFAULT (getdate()) NOT NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_Providers_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Wal_Providers] PRIMARY KEY CLUSTERED ([ProviderId] ASC),
    CONSTRAINT [FK_WAL_Providers_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

