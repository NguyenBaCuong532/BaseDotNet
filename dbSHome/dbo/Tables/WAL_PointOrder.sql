CREATE TABLE [dbo].[WAL_PointOrder] (
    [PointTranId] NVARCHAR (50)    NOT NULL,
    [PointCd]     NVARCHAR (20)    NOT NULL,
    [TranType]    NVARCHAR (50)    NULL,
    [TransNo]     NVARCHAR (50)    NULL,
    [Ref_No]      NVARCHAR (100)   NOT NULL,
    [OrderAmount] DECIMAL (18)     NULL,
    [CreditPoint] DECIMAL (18)     NULL,
    [Point]       DECIMAL (18)     NOT NULL,
    [CurrPoint]   DECIMAL (18)     NULL,
    [TranDt]      DATETIME         NULL,
    [OrderInfo]   NVARCHAR (450)   NULL,
    [ServiceKey]  NVARCHAR (50)    NULL,
    [PosCd]       NVARCHAR (50)    NULL,
    [CltId]       NVARCHAR (50)    NULL,
    [CltIp]       NVARCHAR (50)    NULL,
    [roomCode]    NVARCHAR (30)    NULL,
    [expireDt]    DATETIME         NULL,
    [isFinal]     BIT              NULL,
    [push_st]     INT              NULL,
    [push_dt]     DATETIME         NULL,
    [push_exp_dt] DATETIME         NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_PointOrder_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Point_Trans] PRIMARY KEY CLUSTERED ([PointTranId] ASC),
    CONSTRAINT [FK_WAL_PointOrder_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [IX_WAL_PointOrder_Filter_TranDt_Covering]
    ON [dbo].[WAL_PointOrder]([TranType] ASC, [ServiceKey] ASC, [PosCd] ASC, [expireDt] ASC, [isFinal] ASC, [TranDt] ASC)
    INCLUDE([Ref_No], [OrderAmount], [Point], [CurrPoint], [OrderInfo], [TransNo], [PointCd], [push_st], [push_dt], [push_exp_dt]) WITH (DATA_COMPRESSION = ROW);


GO
CREATE NONCLUSTERED INDEX [IX_WAL_PointOrder_PointCd_TranDt_INCL]
    ON [dbo].[WAL_PointOrder]([PointCd] ASC, [TranDt] ASC)
    INCLUDE([CreditPoint], [expireDt]) WITH (DATA_COMPRESSION = ROW);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20210920-160508]
    ON [dbo].[WAL_PointOrder]([Point] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20210920-154140]
    ON [dbo].[WAL_PointOrder]([OrderAmount] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20210920-153353]
    ON [dbo].[WAL_PointOrder]([expireDt] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20210920-153241]
    ON [dbo].[WAL_PointOrder]([TranDt] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_WAL_PointOrder_TranDt]
    ON [dbo].[WAL_PointOrder]([TranDt] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_WAL_PointOrder_TransNo]
    ON [dbo].[WAL_PointOrder]([TransNo] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_WAL_PointOrder_TranType]
    ON [dbo].[WAL_PointOrder]([TranType] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_WAL_PointOrder_PosCd]
    ON [dbo].[WAL_PointOrder]([PosCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_WAL_PointOrder_ServiceKey]
    ON [dbo].[WAL_PointOrder]([ServiceKey] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_WAL_PointOrder_Ref_No]
    ON [dbo].[WAL_PointOrder]([Ref_No] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_WAL_PointOrder_PointCd]
    ON [dbo].[WAL_PointOrder]([PointCd] ASC);

