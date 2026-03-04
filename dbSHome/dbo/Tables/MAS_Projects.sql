CREATE TABLE [dbo].[MAS_Projects] (
    [oid]                 UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Projects_oid] DEFAULT (newid()) NOT NULL,
    [sub_projectCd]       NVARCHAR (10)    NOT NULL,
    [projectCd]           NVARCHAR (10)    NOT NULL,
    [projectName]         NVARCHAR (250)   NOT NULL,
    [investorName]        NVARCHAR (150)   NOT NULL,
    [address]             NVARCHAR (250)   NOT NULL,
    [timeWorking]         NVARCHAR (150)   NULL,
    [bank_acc_no]         NVARCHAR (50)    NULL,
    [bank_acc_name]       NVARCHAR (250)   NULL,
    [bank_branch]         NVARCHAR (250)   NULL,
    [bank_name]           NVARCHAR (250)   NULL,
    [mailSender]          NVARCHAR (50)    NULL,
    [dayOfIndexElectric]  INT              NULL,
    [dayOfIndexWater]     INT              NULL,
    [caculateVehicleType] INT              NULL,
    [caculateWaterType]   INT              NULL,
    [dayOfNotice1]        DATETIME         NULL,
    [dayOfNotice2]        DATETIME         NULL,
    [dayOfNotice3]        DATETIME         NULL,
    [dayStopService]      DATETIME         NULL,
    [type_discount_elec]  INT              CONSTRAINT [DF_MAS_Projects_type_discount_elec] DEFAULT ((0)) NULL,
    [type_discount_water] INT              NULL,
    [is_proxy_payment]    BIT              CONSTRAINT [DF_MAS_Projects_is_proxy_payment] DEFAULT ((0)) NOT NULL,
    [representative_name] NVARCHAR (50)    NULL,
    [bank_code]           NVARCHAR (60)    NULL,
    [orgId]               UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Projects] PRIMARY KEY CLUSTERED ([oid] ASC)
);












GO
CREATE NONCLUSTERED INDEX [idx_MAS_Projects_projectName]
    ON [dbo].[MAS_Projects]([projectName] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Người đại diện', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_Projects', @level2type = N'COLUMN', @level2name = N'representative_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ủy quyền thu hộ/chi hộ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_Projects', @level2type = N'COLUMN', @level2name = N'is_proxy_payment';

