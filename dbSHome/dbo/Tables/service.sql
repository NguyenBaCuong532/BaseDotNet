CREATE TABLE [dbo].[service] (
    [id]              UNIQUEIDENTIFIER CONSTRAINT [DF_service_id] DEFAULT (newid()) NOT NULL,
    [name]            NVARCHAR (250)   NOT NULL,
    [icon_url]        NVARCHAR (MAX)   NULL,
    [ordinal]         INT              NULL,
    [is_active]       BIT              NULL,
    [has_extra]       BIT              NULL,
    [description]     NVARCHAR (250)   NULL,
    [service_type_id] UNIQUEIDENTIFIER NULL,
    [created_dt]      DATETIME         CONSTRAINT [DF_service_created_dt] DEFAULT (getdate()) NULL,
    [created_by]      UNIQUEIDENTIFIER NULL,
    [updated_dt]      DATETIME         NULL,
    [updated_by]      UNIQUEIDENTIFIER NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_service] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_service_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

