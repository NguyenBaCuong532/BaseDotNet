CREATE TABLE [dbo].[MAS_Service_Living_Tracking] (
    [TrackingId]     INT              IDENTITY (1, 1) NOT NULL,
    [ProjectCd]      NVARCHAR (30)    NULL,
    [periods_oid]    UNIQUEIDENTIFIER NULL,
    [ApartmentId]    INT              NOT NULL,
    [PeriodMonth]    INT              NOT NULL,
    [PeriodYear]     INT              NOT NULL,
    [LivingId]       INT              NOT NULL,
    [FromDt]         DATE             NULL,
    [ToDt]           DATE             NULL,
    [LivingTypeId]   INT              NOT NULL,
    [FromNum]        INT              NULL,
    [ToNum]          INT              NULL,
    [TotalNum]       INT              NULL,
    [Amount]         INT              NULL,
    [DiscountAmt]    DECIMAL (18)     NULL,
    [FreeAmt]        DECIMAL (18)     NULL,
    [lastReceivable] DATETIME         NULL,
    [InputType]      NVARCHAR (50)    NULL,
    [InputId]        INT              NULL,
    [Calculate]      BIGINT           NULL,
    [IsCalculate]    BIT              NULL,
    [IsBill]         BIT              NULL,
    [IsReceivable]   BIT              NULL,
    [trackingSt]     INT              NULL,
    [trackingDt]     DATETIME         NULL,
    [SysDt]          DATETIME         NULL,
    [VatAmt]         DECIMAL (18)     NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Service_Living_Tracking_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    [apartOid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Service_Living_Tracking] PRIMARY KEY CLUSTERED ([TrackingId] ASC),
    CONSTRAINT [FK_MAS_Service_Living_Tracking_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);












GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_Living_Tracking_PeriodYear]
    ON [dbo].[MAS_Service_Living_Tracking]([PeriodYear] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_Living_Tracking_PeriodMonth]
    ON [dbo].[MAS_Service_Living_Tracking]([PeriodMonth] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_Living_Tracking_LivingTypeId]
    ON [dbo].[MAS_Service_Living_Tracking]([LivingTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_Living_Tracking_apartmentId]
    ON [dbo].[MAS_Service_Living_Tracking]([ApartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Tracking_MonthYear_ProjectCd]
    ON [dbo].[MAS_Service_Living_Tracking]([LivingTypeId] ASC, [ToDt] ASC, [ProjectCd] ASC)
    INCLUDE([TrackingId], [TotalNum], [IsReceivable], [ApartmentId]);

