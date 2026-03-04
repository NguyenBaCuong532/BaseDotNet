CREATE TABLE [dbo].[ELE_BuildZone] (
    [Id]         INT              IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [BuildZone]  NVARCHAR (50)    NOT NULL,
    [AreaCd]     NVARCHAR (50)    NULL,
    [ProjectCd]  NVARCHAR (50)    NULL,
    [created_at] DATETIME         CONSTRAINT [DF_ELE_BuildZone_SysDate] DEFAULT (getdate()) NULL,
    [created_by] NVARCHAR (255)   NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_ELE_BuildZone_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ELE_BuildZone] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_ELE_BuildZone_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_ELE_BuildZone_Id] UNIQUE NONCLUSTERED ([Id] ASC)
);








GO
CREATE NONCLUSTERED INDEX [idx_ELE_BuildZone_ProjectCd]
    ON [dbo].[ELE_BuildZone]([ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_ELE_BuildZone_BuildCd]
    ON [dbo].[ELE_BuildZone]([AreaCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_ELE_BuildZone_BuildZoneName]
    ON [dbo].[ELE_BuildZone]([BuildZone] ASC);

