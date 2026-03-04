CREATE TABLE [dbo].[MigrationBaseline_sp_res_apartment_list] (
    [RunId]    INT              NOT NULL,
    [RowNum]   INT              NOT NULL,
    [value]    INT              NULL,
    [apartOid] UNIQUEIDENTIFIER NULL,
    [name]     NVARCHAR (100)   NULL,
    PRIMARY KEY CLUSTERED ([RunId] ASC, [RowNum] ASC),
    FOREIGN KEY ([RunId]) REFERENCES [dbo].[MigrationBaseline_Run] ([RunId])
);

