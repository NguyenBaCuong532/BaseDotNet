CREATE TABLE [dbo].[MAS_report_info] (
    [report_id]     INT              IDENTITY (1, 1) NOT NULL,
    [int_order]     INT              NOT NULL,
    [report_type]   INT              NULL,
    [report_group]  NVARCHAR (100)   NULL,
    [report_name]   NVARCHAR (150)   NOT NULL,
    [template_url]  NVARCHAR (MAX)   NULL,
    [template_type] NVARCHAR (100)   NULL,
    [api_url]       NVARCHAR (MAX)   NULL,
    [active]        BIT              NOT NULL,
    [mkr_id]        NVARCHAR (100)   NULL,
    [mkr_dt]        DATETIME         CONSTRAINT [DF_sipt_report_info_mkr_dt] DEFAULT (getdate()) NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_report_info_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_report_info] PRIMARY KEY CLUSTERED ([report_id] ASC),
    CONSTRAINT [FK_MAS_report_info_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

