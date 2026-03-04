CREATE TABLE [dbo].[MAS_Cards] (
    [CardId]        INT              IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CardCd]        NVARCHAR (50)    NOT NULL,
    [CardTypeId]    INT              NULL,
    [ImageUrl]      NVARCHAR (250)   NULL,
    [IssueDate]     DATETIME         NULL,
    [ExpireDate]    DATETIME         NULL,
    [CustId]        NVARCHAR (50)    NULL,
    [Card_St]       INT              NULL,
    [SelfLock]      BIT              NULL,
    [IsLost]        BIT              NULL,
    [IsVip]         BIT              NULL,
    [CardName]      NVARCHAR (150)   NULL,
    [IsDaily]       BIT              NOT NULL,
    [IsClose]       BIT              NULL,
    [CloseDate]     DATETIME         NULL,
    [RequestId]     INT              NULL,
    [ApartmentId]   INT              NULL,
    [ProjectCd]     NVARCHAR (30)    NULL,
    [VehicleTypeId] INT              NULL,
    [StarLevel]     INT              NULL,
    [IsGuest]       BIT              NULL,
    [isVehicle]     BIT              NULL,
    [isCredit]      BIT              NULL,
    [partner_id]    INT              NULL,
    [created_by]    NVARCHAR (100)   NULL,
    [CloseBy]       NVARCHAR (100)   NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Cards_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    [apartOid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Cards] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_MAS_Cards_apartOid] FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments] ([oid]),
    CONSTRAINT [FK_MAS_Cards_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [Constraint_MAS_Cards_CardId] UNIQUE NONCLUSTERED ([CardId] ASC),
    CONSTRAINT [UQ_MAS_Cards_oid] UNIQUE NONCLUSTERED ([oid] ASC)
);












GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_partner_id]
    ON [dbo].[MAS_Cards]([partner_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_IsGuest]
    ON [dbo].[MAS_Cards]([IsGuest] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_IsVip]
    ON [dbo].[MAS_Cards]([IsVip] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_IsDaily]
    ON [dbo].[MAS_Cards]([IsDaily] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_CardCd]
    ON [dbo].[MAS_Cards]([CardCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_CardTypeId]
    ON [dbo].[MAS_Cards]([CardTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_Card_St]
    ON [dbo].[MAS_Cards]([Card_St] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_ApartmentId]
    ON [dbo].[MAS_Cards]([ApartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_projectCd]
    ON [dbo].[MAS_Cards]([ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_CustId]
    ON [dbo].[MAS_Cards]([CustId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Cards_Cust_St]
    ON [dbo].[MAS_Cards]([CustId] ASC, [Card_St] ASC)
    INCLUDE([CardId], [CardTypeId], [CardCd], [ProjectCd]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Trạng thái user tự khóa thẻ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_Cards', @level2type = N'COLUMN', @level2name = N'SelfLock';

