CREATE TABLE [dbo].[ELE_Floor] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [FloorName]   NVARCHAR (255)   NULL,
    [FloorNumber] INT              NULL,
    [FloorTypeId] INT              NULL,
    [BuildCd]     NVARCHAR (50)    NULL,
    [BuildZoneId] INT              NULL,
    [BuildZone]   NVARCHAR (50)    NULL,
    [ProjectCd]   NVARCHAR (50)    NULL,
    [SysDate]     DATETIME         CONSTRAINT [DF_ELE_Floor_SysDate] DEFAULT (getdate()) NULL,
    [CreatedBy]   NVARCHAR (255)   NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_ELE_Floor_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ELE_Floor] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_ELE_Floor_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_ELE_Floor_Id] UNIQUE NONCLUSTERED ([Id] ASC)
);

