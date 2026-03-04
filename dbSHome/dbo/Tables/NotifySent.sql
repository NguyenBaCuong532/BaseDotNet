CREATE TABLE [dbo].[NotifySent] (
    [id]               BIGINT           IDENTITY (1, 1) NOT NULL,
    [NotiId]           BIGINT           NOT NULL,
    [userId]           NVARCHAR (100)   NULL,
    [custId]           NVARCHAR (100)   NULL,
    [email]            NVARCHAR (200)   NULL,
    [phone]            NVARCHAR (100)   NULL,
    [fullName]         NVARCHAR (250)   NULL,
    [room]             NVARCHAR (50)    NULL,
    [push_st]          INT              NULL,
    [sms_st]           INT              NULL,
    [read_st]          BIT              CONSTRAINT [DF_NotifySent_read_st] DEFAULT ((0)) NULL,
    [read_dt]          DATETIME         NULL,
    [email_st]         INT              NULL,
    [createId]         NVARCHAR (100)   NULL,
    [createDt]         DATETIME         CONSTRAINT [DF_NotifySent_createDt] DEFAULT (getdate()) NULL,
    [n_id]             UNIQUEIDENTIFIER NULL,
    [toId]             UNIQUEIDENTIFIER NULL,
    [Schedule]         DATETIME         NULL,
    [subject]          NVARCHAR (300)   NULL,
    [content_notify]   NVARCHAR (MAX)   NULL,
    [content_sms]      NVARCHAR (600)   NULL,
    [content_email]    NVARCHAR (MAX)   NULL,
    [push_st_message]  NVARCHAR (2000)  NULL,
    [sms_st_message]   NVARCHAR (512)   NULL,
    [email_st_message] NVARCHAR (512)   NULL,
    [external_param]   NVARCHAR (1024)  NULL,
    [GuidId]           UNIQUEIDENTIFIER CONSTRAINT [DF_NotifySent_GuidId] DEFAULT (newid()) NULL,
    [UpdateDate]       DATETIME         NULL,
    [attachs]          UNIQUEIDENTIFIER NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_NotifySent] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_NotifySent_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);












GO
CREATE NONCLUSTERED INDEX [idx_NotifySent_n_id]
    ON [dbo].[NotifySent]([n_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_NotifySent_custId]
    ON [dbo].[NotifySent]([custId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Đặt lịch gửi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifySent', @level2type = N'COLUMN', @level2name = N'Schedule';

