CREATE TABLE [dbo].[WAL_Tranfers] (
    [TranferCd]      NVARCHAR (16)    NOT NULL,
    [IconKey]        NVARCHAR (30)    NULL,
    [TranferName]    NVARCHAR (50)    NOT NULL,
    [TranferViewUrl] NVARCHAR (250)   NULL,
    [IsFee]          BIT              NULL,
    [RateFee]        FLOAT (53)       NULL,
    [FixFee]         INT              NULL,
    [intOrder]       INT              NULL,
    [IsPayment]      BIT              NULL,
    [IsRecharge]     BIT              NULL,
    [IsFlage]        BIT              NULL,
    [CreateDt]       DATETIME         CONSTRAINT [DF_WAL_TranferService_CreateDt] DEFAULT (getdate()) NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_Tranfers_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_TranferService] PRIMARY KEY CLUSTERED ([TranferCd] ASC),
    CONSTRAINT [FK_WAL_Tranfers_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

