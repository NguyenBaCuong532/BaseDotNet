CREATE TABLE [dbo].[MAS_Points_Save] (
    [PointCd]    NVARCHAR (20)    NOT NULL,
    [PointType]  INT              NULL,
    [CustId]     NVARCHAR (50)    NOT NULL,
    [CurrPoint]  DECIMAL (18)     NOT NULL,
    [LastDt]     DATETIME         NULL,
    [sysDate]    DATETIME         NULL,
    [saveDate]   DATETIME         CONSTRAINT [DF_MAS_Points_Save_saveDate] DEFAULT (getdate()) NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Points_Save_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_MAS_Points_Save_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

