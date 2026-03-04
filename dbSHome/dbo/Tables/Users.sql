CREATE TABLE [dbo].[Users] (
    [userId]           UNIQUEIDENTIFIER NOT NULL,
    [reg_dt]           DATETIME         NULL,
    [last_dt]          DATETIME         NULL,
    [admin_st]         BIT              NULL,
    [fullName]         NVARCHAR (100)   NULL,
    [loginName]        VARCHAR (50)     NULL,
    [PasswordHash]     VARBINARY (MAX)  NULL,
    [PasswordSalt]     VARBINARY (MAX)  NULL,
    [phone]            NVARCHAR (20)    NULL,
    [email]            VARCHAR (50)     NULL,
    [position]         NVARCHAR (100)   NULL,
    [created_dt]       DATETIME         CONSTRAINT [DF_Users_SysDate] DEFAULT (getdate()) NOT NULL,
    [parent_id]        UNIQUEIDENTIFIER NULL,
    [created_by]       UNIQUEIDENTIFIER NULL,
    [orgId]            UNIQUEIDENTIFIER NULL,
    [lock_st]          BIT              NULL,
    [lock_dt]          DATETIME         NULL,
    [active]           BIT              NULL,
    [custId]           UNIQUEIDENTIFIER NULL,
    [createdDate]      DATETIME         NULL,
    [LastModifiedBy]   UNIQUEIDENTIFIER NULL,
    [LastModifiedDate] DATETIME         NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_Users_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([userId] ASC),
    CONSTRAINT [FK_Users_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
CREATE NONCLUSTERED INDEX [IX_Users_UserId_Admin]
    ON [dbo].[Users]([userId] ASC, [admin_st] ASC);

