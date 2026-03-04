CREATE TABLE [dbo].[MAS_StationReader] (
    [StationId]   INT              IDENTITY (1, 1) NOT NULL,
    [StationCd]   NVARCHAR (50)    NULL,
    [StationName] NVARCHAR (100)   NOT NULL,
    [ServiceId]   INT              NULL,
    [StartDate]   DATETIME         NULL,
    [Status]      NVARCHAR (50)    NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_StationReader_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_StationReader] PRIMARY KEY CLUSTERED ([StationId] ASC),
    CONSTRAINT [FK_MAS_StationReader_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

