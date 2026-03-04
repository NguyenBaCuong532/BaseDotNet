CREATE TABLE [dbo].[MAS_ServiceProvider] (
    [id]             UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_ServiceProvider_id] DEFAULT (newid()) NOT NULL,
    [ProviderCd]     NVARCHAR (50)    NOT NULL,
    [ProviderShort]  NVARCHAR (100)   NOT NULL,
    [ProviderName]   NVARCHAR (200)   NOT NULL,
    [Address]        NVARCHAR (250)   NULL,
    [LogoUrl]        NVARCHAR (250)   NULL,
    [ContactName]    NVARCHAR (100)   NULL,
    [Phone]          NVARCHAR (30)    NULL,
    [Email]          NVARCHAR (150)   NULL,
    [IsTelephone]    BIT              NULL,
    [ContractTypeId] INT              NULL,
    [DepartmentId]   NVARCHAR (50)    NULL,
    [SysDate]        DATETIME         CONSTRAINT [DF_MAS_TelecomProvider_SysDate] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_TelecomProvider] PRIMARY KEY CLUSTERED ([ProviderCd] ASC),
    CONSTRAINT [FK_MAS_ServiceProvider_rocketchat_department] FOREIGN KEY ([DepartmentId]) REFERENCES [dbo].[rocketchat_department] ([id]),
    CONSTRAINT [FK_MAS_ServiceProvider_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rocketchat departmentId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_ServiceProvider', @level2type = N'COLUMN', @level2name = N'DepartmentId';

