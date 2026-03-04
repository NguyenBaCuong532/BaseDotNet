CREATE TABLE [dbo].[par_residence_type] (
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_ServicePrice_ResidenceType_Oid] DEFAULT (newid()) NOT NULL,
    [config_code] NVARCHAR (50)    NOT NULL,
    [config_name] NVARCHAR (100)   NOT NULL,
    [sort_number] INT              CONSTRAINT [DF_ServicePrice_ResidenceType_SortNumber] DEFAULT ((0)) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ServicePrice_ResidenceType] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_residence_type_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Loại hình căn hộ (Cư dân, cho thuê, dịch vụ...)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'par_residence_type';

