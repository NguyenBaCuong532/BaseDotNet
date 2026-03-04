CREATE TYPE [dbo].[route_point_type] AS TABLE (
    [id]             NVARCHAR (50)  NULL,
    [route_line_id]  NVARCHAR (50)  NOT NULL,
    [route_point_id] NVARCHAR (50)  NOT NULL,
    [seq]            INT            NULL,
    [name]           NVARCHAR (100) NULL,
    [longitude]      FLOAT (53)     NOT NULL,
    [latitude]       FLOAT (53)     NOT NULL,
    [address]        NVARCHAR (250) NULL,
    PRIMARY KEY NONCLUSTERED ([route_line_id] ASC, [route_point_id] ASC));

