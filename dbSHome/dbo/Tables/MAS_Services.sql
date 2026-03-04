CREATE TABLE [dbo].[MAS_Services] (
    [ServiceId]     INT              IDENTITY (1, 1) NOT NULL,
    [ServiceName]   NVARCHAR (150)   NOT NULL,
    [ServiceTypeId] INT              NOT NULL,
    [app_st]        INT              NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Services_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Services] PRIMARY KEY CLUSTERED ([ServiceId] ASC),
    CONSTRAINT [FK_MAS_Services_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

