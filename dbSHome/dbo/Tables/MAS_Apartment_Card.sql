CREATE TABLE [dbo].[MAS_Apartment_Card] (
    [ApartmentId] INT              NOT NULL,
    [CardId]      INT              NOT NULL,
    [rowguid]     UNIQUEIDENTIFIER CONSTRAINT [MSmerge_df_rowguid_DCF6F12B7D5540EE93AC4BF1D987A6BA] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    [apartOid]    UNIQUEIDENTIFIER NULL,
    [cardOid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Apartment_Card] PRIMARY KEY CLUSTERED ([ApartmentId] ASC, [CardId] ASC),
    CONSTRAINT [FK_MAS_Apartment_Card_apartOid] FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments] ([oid]),
    CONSTRAINT [FK_MAS_Apartment_Card_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ__MAS_Apartment_Card__CardId] UNIQUE NONCLUSTERED ([CardId] ASC)
);








GO
CREATE NONCLUSTERED INDEX [IX_Apartment_Card_CardId]
    ON [dbo].[MAS_Apartment_Card]([CardId] ASC, [ApartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Apartment_Card_cardOid]
    ON [dbo].[MAS_Apartment_Card]([cardOid] ASC);

