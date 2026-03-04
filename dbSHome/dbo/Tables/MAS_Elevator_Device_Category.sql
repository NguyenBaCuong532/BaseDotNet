CREATE TABLE [dbo].[MAS_Elevator_Device_Category] (
    [Id]                  INT              IDENTITY (1, 1) NOT NULL,
    [oid]                 UNIQUEIDENTIFIER CONSTRAINT [DF__MAS_Elevato__oid__2FDFDD2E] DEFAULT (newid()) NOT NULL,
    [HardwareId]          NVARCHAR (50)    NOT NULL,
    [ElevatorBank]        INT              NULL,
    [ElevatorShaftName]   NVARCHAR (30)    NULL,
    [ElevatorShaftNumber] INT              NULL,
    [ProjectCd]           NVARCHAR (30)    NULL,
    [buildingCd]          NVARCHAR (50)    NULL,
    [IsActived]           BIT              NULL,
    [created_at]          DATETIME         CONSTRAINT [DF__MAS_Eleva__creat__2EEBB8F5] DEFAULT (getdate()) NULL,
    [created_by]          UNIQUEIDENTIFIER NULL,
    [tenant_oid]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Elevator_Device_Category] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_MAS_Elevator_Device_Category_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_MAS_Elevator_Device_Category_Id] UNIQUE NONCLUSTERED ([Id] ASC)
);

