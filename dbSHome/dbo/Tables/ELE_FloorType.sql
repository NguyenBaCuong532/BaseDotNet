CREATE TABLE [dbo].[ELE_FloorType] (
    [Id]            INT              IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FloorTypeName] NVARCHAR (50)    NOT NULL,
    [BuildCd]       NVARCHAR (50)    NULL,
    [SysDate]       DATETIME         CONSTRAINT [DF_ELE_FloorType_SysDate] DEFAULT (getdate()) NULL,
    [CreatedBy]     NVARCHAR (255)   NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_ELE_FloorType_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ELE_FloorType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ELE_FloorType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

