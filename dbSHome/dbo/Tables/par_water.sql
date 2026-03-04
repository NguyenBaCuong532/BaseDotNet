CREATE TABLE [dbo].[par_water] (
    [oid]                        UNIQUEIDENTIFIER CONSTRAINT [DF_par_water_oid] DEFAULT (newid()) NOT NULL,
    [project_code]               NVARCHAR (50)    NOT NULL,
    [par_residence_type_oid]     UNIQUEIDENTIFIER NOT NULL,
    [par_service_price_type_oid] UNIQUEIDENTIFIER NULL,
    [effective_date]             DATETIME         NULL,
    [expiry_date]                DATETIME         NULL,
    [is_active]                  BIT              CONSTRAINT [DF_par_water_is_active] DEFAULT ((0)) NOT NULL,
    [note]                       NVARCHAR (200)   NULL,
    [created_user]               UNIQUEIDENTIFIER NOT NULL,
    [created_date]               DATETIME         CONSTRAINT [DF_par_water_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]           UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date]         DATETIME         CONSTRAINT [DF_par_water_last_modified_date] DEFAULT (getdate()) NOT NULL,
    [vat]                        DECIMAL (18)     NULL,
    [environmental_fee]          DECIMAL (18)     NULL,
    [env_protection_tax]         DECIMAL (18, 2)  NULL,
    [tenant_oid]                 UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_par_water] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_water_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'phí môi trường', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_water', @level2type = N'COLUMN', @level2name = N'environmental_fee';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Thuế bảo vệ môi trường', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_water', @level2type = N'COLUMN', @level2name = N'env_protection_tax';

