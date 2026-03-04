CREATE TABLE [dbo].[MAS_report_param] (
    [id]            BIGINT           IDENTITY (1, 1) NOT NULL,
    [report_id]     INT              NOT NULL,
    [param_cd]      NVARCHAR (50)    NOT NULL,
    [param_name]    NVARCHAR (100)   NULL,
    [param_type]    NVARCHAR (50)    NOT NULL,
    [param_default] NVARCHAR (200)   NULL,
    [create_dt]     DATETIME         CONSTRAINT [DF_inv_report_param_create_dt] DEFAULT (getdate()) NOT NULL,
    [param_object]  NVARCHAR (50)    NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_report_param_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_report_param] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_MAS_report_param_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

