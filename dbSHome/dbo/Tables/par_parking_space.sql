CREATE TABLE [dbo].[par_parking_space] (
    [oid]                UNIQUEIDENTIFIER CONSTRAINT [DF_par_parking_space_oid] DEFAULT (newid()) NOT NULL,
    [project_code]       NVARCHAR (50)    NOT NULL,
    [vehicle_type]       INT              NOT NULL,
    [space_count]        INT              NOT NULL,
    [created_user]       UNIQUEIDENTIFIER NOT NULL,
    [created_date]       DATETIME         CONSTRAINT [DF_par_parking_space_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]   UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date] DATETIME         CONSTRAINT [DF_par_parking_space_updated_date] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_par_parking_space] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_parking_space_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

