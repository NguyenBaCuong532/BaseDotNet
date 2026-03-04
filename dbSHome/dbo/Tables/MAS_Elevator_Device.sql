CREATE TABLE [dbo].[MAS_Elevator_Device] (
    [Id]                  INT              IDENTITY (1, 1) NOT NULL,
    [HardwareId]          NVARCHAR (50)    NOT NULL,
    [FloorNumber]         INT              NOT NULL,
    [FloorName]           NVARCHAR (50)    NOT NULL,
    [ElevatorBank]        INT              NULL,
    [ElevatorShaftName]   NVARCHAR (30)    NULL,
    [ElevatorShaftNumber] INT              NULL,
    [ProjectCd]           NVARCHAR (30)    NULL,
    [AreaCd]              NVARCHAR (50)    NULL,
    [BuildZone]           NVARCHAR (50)    NULL,
    [IsActived]           BIT              NULL,
    [created_at]          DATETIME         CONSTRAINT [DF_MAS_Elevator_Device_created_at] DEFAULT (getdate()) NULL,
    [created_by]          UNIQUEIDENTIFIER NULL,
    [buildingCd]          NVARCHAR (50)    NULL,
    [oid]                 UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Elevator_Device_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Elevator_Device] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_MAS_Elevator_Device_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_MAS_Elevator_Device_HardwareId] UNIQUE NONCLUSTERED ([HardwareId] ASC)
);














GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Device_IsActived]
    ON [dbo].[MAS_Elevator_Device]([IsActived] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Device_BuildZone]
    ON [dbo].[MAS_Elevator_Device]([BuildZone] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Device_BuildCd]
    ON [dbo].[MAS_Elevator_Device]([AreaCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Device_ProjectCd]
    ON [dbo].[MAS_Elevator_Device]([ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_EDev_Project_BuildZone]
    ON [dbo].[MAS_Elevator_Device]([ProjectCd] ASC, [BuildZone] ASC)
    INCLUDE([HardwareId], [IsActived]);


GO
CREATE NONCLUSTERED INDEX [IX_EDev_Hardware_Active]
    ON [dbo].[MAS_Elevator_Device]([HardwareId] ASC)
    INCLUDE([ProjectCd], [BuildZone], [IsActived]);

