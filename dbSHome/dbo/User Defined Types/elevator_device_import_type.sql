CREATE TYPE [dbo].[elevator_device_import_type] AS TABLE (
    [seq]                 INT            NULL,
    [projectCd]           NVARCHAR (50)  NULL,
    [buildCd]             NVARCHAR (50)  NULL,
    [hardwareId]          NVARCHAR (100) NULL,
    [buildZone]           NVARCHAR (100) NULL,
    [floorName]           NVARCHAR (100) NULL,
    [elevatorBank]        NVARCHAR (50)  NULL,
    [elevatorShaftName]   NVARCHAR (100) NULL,
    [elevatorShaftNumber] INT            NULL,
    [floorNumber]         INT            NULL,
    [isActive]            BIT            NULL);

