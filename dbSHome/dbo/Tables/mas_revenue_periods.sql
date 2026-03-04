CREATE TABLE [dbo].[mas_revenue_periods] (
    [oid]               UNIQUEIDENTIFIER NOT NULL,
    [project_code]      NVARCHAR (50)    NOT NULL,
    [period_code]       VARCHAR (50)     NOT NULL,
    [period_name]       NVARCHAR (100)   NULL,
    [locked]            BIT              CONSTRAINT [DF_mas_revenue_periods_locked] DEFAULT ((0)) NOT NULL,
    [start_date]        DATE             NOT NULL,
    [end_date]          DATE             NOT NULL,
    [created_by]        UNIQUEIDENTIFIER NULL,
    [created_date]      DATETIME         CONSTRAINT [DF__mas_reven__creat__5EE41983] DEFAULT (sysdatetime()) NOT NULL,
    [last_updated_by]   UNIQUEIDENTIFIER NULL,
    [last_updated_date] DATETIME         CONSTRAINT [DF__mas_reven__last___5FD83DBC] DEFAULT (sysdatetime()) NOT NULL,
    CONSTRAINT [PK__mas_reve__C2FFCF13D202F15D] PRIMARY KEY CLUSTERED ([oid] ASC)
);

