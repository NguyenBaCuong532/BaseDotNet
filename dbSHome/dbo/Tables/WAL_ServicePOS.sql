CREATE TABLE [dbo].[WAL_ServicePOS] (
    [PosCd]                  NVARCHAR (30)    NOT NULL,
    [ServiceKey]             NVARCHAR (16)    NOT NULL,
    [PosName]                NVARCHAR (50)    NOT NULL,
    [Address]                NVARCHAR (250)   NULL,
    [IsPayment]              BIT              NULL,
    [IsRecharge]             BIT              NULL,
    [IsSPay]                 BIT              NULL,
    [IsActive]               BIT              NULL,
    [CreateDt]               DATETIME         NULL,
    [callbackUrl]            NVARCHAR (350)   NULL,
    [callbackChecksumSecret] NVARCHAR (100)   NULL,
    [projectCd]              NVARCHAR (20)    NULL,
    [hotline]                NVARCHAR (20)    NULL,
    [email]                  NVARCHAR (250)   NULL,
    [oid]                    UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_ServicePOS_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]             UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_ServicePOS] PRIMARY KEY CLUSTERED ([PosCd] ASC),
    CONSTRAINT [FK_WAL_ServicePOS_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_WAL_ServicePOS_PosName]
    ON [dbo].[WAL_ServicePOS]([PosName] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_WAL_ServicePOS_ServiceKey]
    ON [dbo].[WAL_ServicePOS]([ServiceKey] ASC);

