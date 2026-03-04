CREATE TYPE [dbo].[apartment_import_type] AS TABLE (
    [seq]          INT            NULL,
    [projectCd]    NVARCHAR (450) NULL,
    [buildingCd]   NVARCHAR (450) NULL,
    [floorName]    NVARCHAR (450) NULL,
    [roomCode]     NVARCHAR (450) NULL,
    [wallArea]     NVARCHAR (450) NULL,
    [waterwayArea] NVARCHAR (450) NULL,
    [isReceived]   NVARCHAR (450) NULL,
    [receiveDt]    NVARCHAR (450) NULL,
    [isRent]       NVARCHAR (450) NULL,
    [feeStart]     NVARCHAR (450) NULL,
    [numFeeMonth]  NVARCHAR (450) NULL);

