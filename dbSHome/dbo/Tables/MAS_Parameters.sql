CREATE TABLE [dbo].[MAS_Parameters] (
    [Category]   NVARCHAR (250)   NOT NULL,
    [Name]       NVARCHAR (250)   NOT NULL,
    [Value]      NVARCHAR (250)   NULL,
    [Ordering]   INT              NULL,
    [ValueInt]   INT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Parameters_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_MAS_Parameters_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

