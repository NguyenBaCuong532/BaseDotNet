CREATE TABLE [dbo].[MAS_CardVehicle_Image] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [CardVehicleId] INT              NOT NULL,
    [ImageLink]     NVARCHAR (300)   NOT NULL,
    [ImageType]     VARCHAR (50)     NULL,
    [created]       DATETIME         NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardVehicle_Image_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CardVehicle_Image] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MAS_CardVehicle_Image_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Loại ảnh: LICENSE, LICENSE_PLATE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Image', @level2type = N'COLUMN', @level2name = N'ImageType';

