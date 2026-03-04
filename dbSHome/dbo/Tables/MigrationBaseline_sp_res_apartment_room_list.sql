CREATE TABLE [dbo].[MigrationBaseline_sp_res_apartment_room_list] (
    [RunId]  INT            NOT NULL,
    [RowNum] INT            NOT NULL,
    [name]   NVARCHAR (100) NULL,
    [value]  NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([RunId] ASC, [RowNum] ASC),
    FOREIGN KEY ([RunId]) REFERENCES [dbo].[MigrationBaseline_Run] ([RunId])
);

