CREATE TABLE [dbo].[PAR_TelecomPrice] (
    [PriceId]     INT              IDENTITY (1, 1) NOT NULL,
    [ProjectCd]   NVARCHAR (30)    NULL,
    [ProviderCd]  NVARCHAR (50)    NULL,
    [PriceCode]   NVARCHAR (50)    NULL,
    [PriceName]   NVARCHAR (100)   NULL,
    [SpeedUD]     INT              NULL,
    [BaseFee]     INT              NULL,
    [DevicePrice] INT              NULL,
    [BasePrice]   INT              NULL,
    [ThreePrice]  INT              NULL,
    [SixPrice]    INT              NULL,
    [YearPrice]   INT              NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_PAR_TelecomPrice_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_PAR_InternetPrice] PRIMARY KEY CLUSTERED ([PriceId] ASC),
    CONSTRAINT [FK_PAR_TelecomPrice_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

