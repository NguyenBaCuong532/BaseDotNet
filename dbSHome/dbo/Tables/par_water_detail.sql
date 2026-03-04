CREATE TABLE [dbo].[par_water_detail] (
    [oid]                UNIQUEIDENTIFIER CONSTRAINT [DF_par_water_detail_oid] DEFAULT (newid()) NOT NULL,
    [par_water_oid]      UNIQUEIDENTIFIER NOT NULL,
    [config_name]        NVARCHAR (100)   NULL,
    [start_value]        DECIMAL (18)     NULL,
    [end_value]          DECIMAL (18)     NULL,
    [unit_price]         DECIMAL (18, 2)  NOT NULL,
    [sort_order]         INT              CONSTRAINT [DF_par_water_detail_sort_order] DEFAULT ((0)) NOT NULL,
    [created_user]       UNIQUEIDENTIFIER NOT NULL,
    [created_date]       DATETIME         CONSTRAINT [DF_par_water_detail_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]   UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date] DATETIME         CONSTRAINT [DF_par_water_detail_last_modified_date] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_par_water_detail] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_water_detail_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

