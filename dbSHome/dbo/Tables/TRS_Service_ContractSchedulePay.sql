CREATE TABLE [dbo].[TRS_Service_ContractSchedulePay] (
    [SchedulePayId]   INT              IDENTITY (1, 1) NOT NULL,
    [ContractId]      INT              NOT NULL,
    [PayType]         INT              NULL,
    [ContractPriceId] INT              NULL,
    [Term]            INT              NULL,
    [Extant]          INT              NULL,
    [ExpireDate]      DATE             NULL,
    [BasePrice]       INT              NULL,
    [DevicePrice]     INT              NULL,
    [TermPrice]       INT              NULL,
    [TotalAmount]     BIGINT           NULL,
    [AutoRenewal]     BIT              NULL,
    [lastReceivable]  DATETIME         NULL,
    [sysDate]         DATETIME         NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_Service_ContractSchedulePay_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_Service_ContractSchedulePay] PRIMARY KEY CLUSTERED ([SchedulePayId] ASC),
    CONSTRAINT [FK_TRS_Service_ContractSchedulePay_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

