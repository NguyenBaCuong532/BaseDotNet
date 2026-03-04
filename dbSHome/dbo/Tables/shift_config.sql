CREATE TABLE [dbo].[shift_config] (
    [prọect_code] NVARCHAR (50)    NOT NULL,
    [day_start]   TIME (7)         DEFAULT ('06:00') NOT NULL,
    [night_start] TIME (7)         DEFAULT ('18:00') NOT NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_shift_config_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_shift_config_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

