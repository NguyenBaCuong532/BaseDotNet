CREATE TABLE [dbo].[COR_Countries] (
    [CountryCd]   NVARCHAR (20)    NOT NULL,
    [CountryName] NVARCHAR (100)   NOT NULL,
    [Flag]        BIT              NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_COR_Countries_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([CountryCd] ASC),
    CONSTRAINT [FK_COR_Countries_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [IDX_COR_Countries_CountryCd]
    ON [dbo].[COR_Countries]([CountryCd] ASC);

