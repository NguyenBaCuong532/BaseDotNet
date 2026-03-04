CREATE TABLE [dbo].[ReportInfo] (
    [report_id]        INT              IDENTITY (1, 1) NOT NULL,
    [int_order]        INT              NOT NULL,
    [report_type]      INT              NULL,
    [report_group]     NVARCHAR (100)   NULL,
    [report_name]      NVARCHAR (150)   NOT NULL,
    [api_url_view]     NVARCHAR (MAX)   NULL,
    [groupKey]         NVARCHAR (100)   NULL,
    [api_url_dowload]  NVARCHAR (MAX)   NULL,
    [active]           BIT              NOT NULL,
    [mkr_id]           NVARCHAR (100)   NULL,
    [mkr_dt]           DATETIME         CONSTRAINT [DF_hrm_report_info_mkr_dt] DEFAULT (getdate()) NULL,
    [createdDate]      DATETIME         CONSTRAINT [DF_ReportInfo_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModifiedBy]   NVARCHAR (250)   NULL,
    [LastModifiedDate] DATETIME         NULL,
    [ParameterDefault] NVARCHAR (50)    NULL,
    [Oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_ReportInfo_Oid] DEFAULT (newid()) NULL,
    [version]          NVARCHAR (50)    NULL,
    CONSTRAINT [PK_hrm_report_info] PRIMARY KEY CLUSTERED ([report_id] ASC) WITH (FILLFACTOR = 70)
);

