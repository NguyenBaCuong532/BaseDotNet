CREATE TABLE [dbo].[MAS_PartnerType] (
    [partner_type_id] INT              IDENTITY (1, 1) NOT NULL,
    [type_cd]         NVARCHAR (50)    NULL,
    [type_name]       NVARCHAR (100)   NOT NULL,
    [is_active]       BIT              CONSTRAINT [DF_MAS_PartnerType_is_active] DEFAULT ((1)) NOT NULL,
    [create_dt]       DATETIME         CONSTRAINT [DF_MAS_PartnerType_create_dt] DEFAULT (getdate()) NOT NULL,
    [create_by]       UNIQUEIDENTIFIER NULL,
    [update_dt]       DATETIME         NULL,
    [update_by]       UNIQUEIDENTIFIER NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([partner_type_id] ASC),
    CONSTRAINT [FK_MAS_PartnerType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_MAS_PartnerType_type_name]
    ON [dbo].[MAS_PartnerType]([type_name] ASC);

