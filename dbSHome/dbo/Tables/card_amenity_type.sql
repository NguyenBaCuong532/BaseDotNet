CREATE TABLE [dbo].[card_amenity_type] (
    [id]         UNIQUEIDENTIFIER CONSTRAINT [DF_card_amenity_type_id] DEFAULT (newid()) NOT NULL,
    [code]       NVARCHAR (50)    NOT NULL,
    [name]       NVARCHAR (250)   NOT NULL,
    [ordinal]    INT              NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_card_amenity_type] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_card_amenity_type_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

