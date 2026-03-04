CREATE TYPE [dbo].[LivingImportType] AS TABLE (
    [room_code]    NVARCHAR (50) NULL,
    [period_month] NVARCHAR (50) NULL,
    [period_year]  NVARCHAR (50) NULL,
    [from_dt]      NVARCHAR (50) NULL,
    [to_dt]        NVARCHAR (50) NULL,
    [from_num]     NVARCHAR (50) NULL,
    [to_num]       NVARCHAR (50) NULL);

