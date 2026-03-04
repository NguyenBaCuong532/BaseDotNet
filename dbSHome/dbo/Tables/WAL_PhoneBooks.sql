CREATE TABLE [dbo].[WAL_PhoneBooks] (
    [Id]          BIGINT           IDENTITY (1, 1) NOT NULL,
    [UserId]      NVARCHAR (450)   NOT NULL,
    [FullName]    NVARCHAR (300)   NULL,
    [AvatarUrl]   NVARCHAR (250)   NULL,
    [ContactName] NVARCHAR (100)   NULL,
    [Phone]       NVARCHAR (50)    NULL,
    [Email]       NVARCHAR (150)   NULL,
    [isWallet]    BIT              NULL,
    [walletCd]    NVARCHAR (20)    NULL,
    [CreateDt]    DATETIME         CONSTRAINT [DF_WAL_PhoneBooks_SysDate] DEFAULT (getdate()) NOT NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_PhoneBooks_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_PhoneBooks] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_WAL_PhoneBooks_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

