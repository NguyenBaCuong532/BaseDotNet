CREATE TYPE [dbo].[user_notify_type] AS TABLE (
    [userid]       NVARCHAR (100) NULL,
    [avatar]       NVARCHAR (400) NULL,
    [fullName]     NVARCHAR (250) NULL,
    [phone]        NVARCHAR (30)  NULL,
    [email]        NVARCHAR (300) NULL,
    [sendDt]       NVARCHAR (20)  NULL,
    [custId]       NVARCHAR (100) NULL,
    [notiId]       BIGINT         NOT NULL,
    [room]         NVARCHAR (30)  NULL,
    [isLinkApp]    BIT            NULL,
    [emailConfirm] BIT            NULL,
    [push_status]  NVARCHAR (50)  NULL,
    [sms_status]   NVARCHAR (50)  NULL,
    [email_status] NVARCHAR (50)  NULL,
    [Id]           BIGINT         NULL);

