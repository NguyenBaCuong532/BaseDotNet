CREATE TABLE [dbo].[WAL_Profile] (
    [WalletCd]         NVARCHAR (16)    NOT NULL,
    [BaseCif]          NVARCHAR (50)    NOT NULL,
    [UserId]           NVARCHAR (250)   NULL,
    [AccountType]      NVARCHAR (50)    NULL,
    [Legacy_AC]        NVARCHAR (12)    NULL,
    [CurrAmount]       BIGINT           NOT NULL,
    [PaymentLimit]     BIGINT           NULL,
    [CreateDt]         DATETIME         NULL,
    [LastDt]           DATETIME         NULL,
    [LinkId]           INT              NULL,
    [LinkedID]         INT              NULL,
    [isRequirePincode] BIT              NULL,
    [Pincode]          NVARCHAR (50)    NULL,
    [isRequestPincode] BIT              NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_Profile_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_Profile] PRIMARY KEY CLUSTERED ([WalletCd] ASC),
    CONSTRAINT [FK_WAL_Profile_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_WAL_Profile_BaseCif]
    ON [dbo].[WAL_Profile]([BaseCif] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_WAL_Profile_BaseCif]
    ON [dbo].[WAL_Profile]([BaseCif] ASC)
    INCLUDE([WalletCd], [CurrAmount], [PaymentLimit], [LinkId], [isRequirePincode], [LinkedID]);

