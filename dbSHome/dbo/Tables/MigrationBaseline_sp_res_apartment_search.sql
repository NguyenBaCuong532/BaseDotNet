CREATE TABLE [dbo].[MigrationBaseline_sp_res_apartment_search] (
    [RunId]       INT              NOT NULL,
    [RowNum]      INT              NOT NULL,
    [ApartmentId] INT              NULL,
    [apartOid]    UNIQUEIDENTIFIER NULL,
    [RoomCode]    NVARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([RunId] ASC, [RowNum] ASC),
    FOREIGN KEY ([RunId]) REFERENCES [dbo].[MigrationBaseline_Run] ([RunId])
);

