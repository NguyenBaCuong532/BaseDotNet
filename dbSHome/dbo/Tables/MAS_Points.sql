CREATE TABLE [dbo].[MAS_Points] (
    [PointCd]    NVARCHAR (20)    NOT NULL,
    [PointType]  INT              NULL,
    [CustId]     NVARCHAR (50)    NOT NULL,
    [CurrPoint]  DECIMAL (18)     NOT NULL,
    [LastDt]     DATETIME         NULL,
    [sysDate]    DATETIME         CONSTRAINT [DF_MAS_Points_sysDate] DEFAULT (getdate()) NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Points_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Points] PRIMARY KEY CLUSTERED ([PointCd] ASC),
    CONSTRAINT [FK_MAS_Points_MAS_Customers] FOREIGN KEY ([CustId]) REFERENCES [dbo].[MAS_Customers] ([CustId]),
    CONSTRAINT [FK_MAS_Points_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [IX_MAS_Points_CustId_INC_CurrPoint]
    ON [dbo].[MAS_Points]([CustId] ASC)
    INCLUDE([CurrPoint]) WITH (DATA_COMPRESSION = ROW);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Points_CustId]
    ON [dbo].[MAS_Points]([CustId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MAS_Points_index_sysDate]
    ON [dbo].[MAS_Points]([sysDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Points_CustId]
    ON [dbo].[MAS_Points]([CustId] ASC)
    INCLUDE([CurrPoint]);

