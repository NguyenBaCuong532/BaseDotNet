CREATE TABLE [dbo].[UserAgree] (
    [userId]     UNIQUEIDENTIFIER NULL,
    [reg_dt]     DATETIME         NULL,
    [last_dt]    DATETIME         NULL,
    [referal_cd] NVARCHAR (20)    NULL,
    [confirm_dt] DATETIME         NULL,
    [confirm_cd] VARCHAR (10)     NULL,
    [agreed_st]  BIT              NULL,
    [agreed_dt]  DATETIME         NULL,
    [signed_st]  BIT              NULL,
    [signed_dt]  DATETIME         NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_UserAgree_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_UserAgree_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

