CREATE TABLE [dbo].[WAL_Services] (
    [ServiceKey]     NVARCHAR (16)    NOT NULL,
    [WalServiceCd]   NVARCHAR (16)    NOT NULL,
    [IconKey]        NVARCHAR (30)    NULL,
    [ServiceName]    NVARCHAR (50)    NOT NULL,
    [Description]    NVARCHAR (150)   NULL,
    [ServiceViewUrl] NVARCHAR (250)   NULL,
    [intOrder]       INT              NULL,
    [IsInPay]        BIT              NULL,
    [IsInRecharge]   BIT              NULL,
    [IsInList]       BIT              NULL,
    [IsFlage]        BIT              NULL,
    [ProviderCd]     NVARCHAR (50)    NULL,
    [PosCd]          NVARCHAR (20)    NULL,
    [IsWallet]       BIT              CONSTRAINT [DF_WAL_Services_IsWallet] DEFAULT ((0)) NULL,
    [CreateDt]       DATETIME         CONSTRAINT [DF_WAL_Services_CreateDt] DEFAULT (getdate()) NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_Services_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_Services] PRIMARY KEY CLUSTERED ([WalServiceCd] ASC),
    CONSTRAINT [FK_WAL_Services_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [Constraint_WAL_Services_ServiceKey] UNIQUE NONCLUSTERED ([ServiceKey] ASC)
);






GO
CREATE NONCLUSTERED INDEX [idx_WAL_Services_ServiceName]
    ON [dbo].[WAL_Services]([ServiceName] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_WAL_Services_ServiceKey]
    ON [dbo].[WAL_Services]([ServiceKey] ASC);

