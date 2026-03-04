CREATE TABLE [dbo].[MAS_PartnerStatus] (
    [status_id]     INT              IDENTITY (1, 1) NOT NULL,
    [status_cd]     VARCHAR (50)     NOT NULL,
    [status_name]   NVARCHAR (100)   NOT NULL,
    [is_active]     BIT              CONSTRAINT [DF_MAS_PartnerStatus_is_active] DEFAULT ((1)) NOT NULL,
    [display_order] INT              NOT NULL,
    [create_dt]     DATETIME         CONSTRAINT [DF_MAS_PartnerStatus_create_dt] DEFAULT (getdate()) NOT NULL,
    [create_by]     VARCHAR (50)     NULL,
    [update_dt]     DATETIME         NULL,
    [update_by]     VARCHAR (50)     NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_PartnerStatus] PRIMARY KEY CLUSTERED ([status_id] ASC),
    CONSTRAINT [FK_MAS_PartnerStatus_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_MAS_PartnerStatus_status_cd] UNIQUE NONCLUSTERED ([status_cd] ASC)
);

