CREATE TABLE [dbo].[ELE_BuildArea] (
    [Id]         INT              IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AreaCd]     NVARCHAR (50)    NOT NULL,
    [AreaName]   NVARCHAR (255)   NOT NULL,
    [ProjectCd]  NVARCHAR (30)    NOT NULL,
    [created_at] DATETIME         CONSTRAINT [DF_ELE_BuildArea_SysDate] DEFAULT (getdate()) NULL,
    [created_by] NVARCHAR (255)   NULL,
    [BuildingId] NVARCHAR (50)    NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_ELE_BuildArea_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ELE_BuildArea] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_ELE_BuildArea_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_ELE_BuildArea_Id] UNIQUE NONCLUSTERED ([Id] ASC)
);

