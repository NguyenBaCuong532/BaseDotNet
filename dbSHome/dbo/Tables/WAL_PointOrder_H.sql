CREATE TABLE [dbo].[WAL_PointOrder_H] (
    [PointTranId] NVARCHAR (50)    NOT NULL,
    [PointCd]     NVARCHAR (20)    NOT NULL,
    [TranType]    NVARCHAR (50)    NULL,
    [TransNo]     NVARCHAR (50)    NULL,
    [Ref_No]      NVARCHAR (100)   NOT NULL,
    [OrderAmount] INT              NULL,
    [CreditPoint] INT              NULL,
    [Point]       INT              NOT NULL,
    [CurrPoint]   INT              NULL,
    [TranDt]      DATETIME         NULL,
    [OrderInfo]   NVARCHAR (450)   NULL,
    [ServiceKey]  NVARCHAR (50)    NULL,
    [PosCd]       NVARCHAR (50)    NULL,
    [CltId]       NVARCHAR (50)    NULL,
    [CltIp]       NVARCHAR (50)    NULL,
    [SaveDt]      DATETIME         NULL,
    [SaveBy]      NVARCHAR (50)    NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_PointOrder_H_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_PointOrder_H] PRIMARY KEY CLUSTERED ([PointTranId] ASC),
    CONSTRAINT [FK_WAL_PointOrder_H_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

