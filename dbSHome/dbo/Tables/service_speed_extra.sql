CREATE TABLE [dbo].[service_speed_extra] (
    [id]          UNIQUEIDENTIFIER CONSTRAINT [DF_service_speed_extra_id] DEFAULT (newid()) NOT NULL,
    [name]        NVARCHAR (250)   NULL,
    [description] NVARCHAR (250)   NULL,
    [price]       DECIMAL (18)     NULL,
    [ordinal]     INT              NULL,
    [created_dt]  DATETIME         CONSTRAINT [DF_service_speed_extra_created_dt] DEFAULT (getdate()) NULL,
    [created_by]  UNIQUEIDENTIFIER NULL,
    [updated_dt]  DATETIME         NULL,
    [updated_by]  UNIQUEIDENTIFIER NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_service_speed_extra] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_service_speed_extra_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

