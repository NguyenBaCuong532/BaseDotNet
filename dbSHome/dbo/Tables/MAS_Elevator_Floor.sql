CREATE TABLE [dbo].[MAS_Elevator_Floor] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [ProjectCd]   NVARCHAR (30)    NULL,
    [AreaCd]      NVARCHAR (50)    NULL,
    [BuildZone]   NVARCHAR (50)    NOT NULL,
    [FloorName]   NVARCHAR (50)    NULL,
    [FloorType]   NVARCHAR (50)    NOT NULL,
    [FloorNumber] INT              NOT NULL,
    [created_at]  DATETIME         CONSTRAINT [DF_MAS_Elevator_Floor_SysDate] DEFAULT (getdate()) NULL,
    [buildingCd]  NVARCHAR (50)    NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Elevator_Floor_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    [buildingOid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Elevator_Floor] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_MAS_Elevator_Floor_buildingOid] FOREIGN KEY ([buildingOid]) REFERENCES [dbo].[MAS_Buildings] ([oid]),
    CONSTRAINT [FK_MAS_Elevator_Floor_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_MAS_Elevator_Floor_Id] UNIQUE NONCLUSTERED ([Id] ASC)
);












GO
CREATE NONCLUSTERED INDEX [IX_Floor_Project_Zone]
    ON [dbo].[MAS_Elevator_Floor]([ProjectCd] ASC, [BuildZone] ASC)
    INCLUDE([buildingCd], [AreaCd], [FloorNumber], [FloorType], [FloorName]);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Floor_ProjectCd]
    ON [dbo].[MAS_Elevator_Floor]([ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Floor_FloorType]
    ON [dbo].[MAS_Elevator_Floor]([FloorType] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Floor_FloorNumber]
    ON [dbo].[MAS_Elevator_Floor]([FloorNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Floor_FloorName]
    ON [dbo].[MAS_Elevator_Floor]([FloorName] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Floor_BuildZone]
    ON [dbo].[MAS_Elevator_Floor]([BuildZone] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Floor_BuildCd]
    ON [dbo].[MAS_Elevator_Floor]([AreaCd] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Elevator_Floor_buildingOid]
    ON [dbo].[MAS_Elevator_Floor]([buildingOid] ASC);

