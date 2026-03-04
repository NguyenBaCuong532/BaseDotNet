CREATE TABLE [dbo].[NotifyInbox] (
    [notiId]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [notiDt]           DATETIME         CONSTRAINT [DF_NotifyInbox_notiDt] DEFAULT (getdate()) NULL,
    [notiType]         INT              NULL,
    [subject]          NVARCHAR (500)   NULL,
    [actionlist]       NVARCHAR (150)   NULL,
    [content_notify]   NVARCHAR (2000)  NULL,
    [content_sms]      NVARCHAR (2000)  NULL,
    [content_type]     INT              NULL,
    [content_markdown] NVARCHAR (MAX)   NULL,
    [content_email]    NVARCHAR (MAX)   NULL,
    [attachs]          UNIQUEIDENTIFIER NULL,
    [bodytype]         NVARCHAR (10)    NULL,
    [isPublish]        BIT              NULL,
    [external_key]     NVARCHAR (50)    NULL,
    [external_param]   NVARCHAR (MAX)   NULL,
    [external_event]   NVARCHAR (50)    NULL,
    [source_key]       NVARCHAR (50)    NULL,
    [source_ref]       UNIQUEIDENTIFIER NULL,
    [clientId]         NVARCHAR (50)    NULL,
    [createId]         NVARCHAR (100)   NULL,
    [createDt]         DATETIME         CONSTRAINT [DF_Notification_SysDate] DEFAULT (getdate()) NULL,
    [send_by]          NVARCHAR (200)   NULL,
    [send_name]        NVARCHAR (50)    NULL,
    [brand_name]       NVARCHAR (20)    NULL,
    [bcc]              NVARCHAR (MAX)   NULL,
    [n_id]             UNIQUEIDENTIFIER CONSTRAINT [DF_NotifyInbox_n_id] DEFAULT (newid()) NULL,
    [source_id]        UNIQUEIDENTIFIER NULL,
    [push_count]       INT              NULL,
    [sms_count]        INT              NULL,
    [email_count]      INT              NULL,
    [notiAvatarUrl]    NVARCHAR (350)   NULL,
    [isHighLight]      BIT              CONSTRAINT [DF_NotifyInbox_isHighLight] DEFAULT ((0)) NULL,
    [external_sub]     NVARCHAR (50)    NULL,
    [tempId]           UNIQUEIDENTIFIER NULL,
    [Schedule]         DATETIME         NULL,
    [send_st]          INT              NULL,
    [sourceId]         UNIQUEIDENTIFIER NULL,
    [is_act_push]      BIT              NULL,
    [is_act_sms]       BIT              NULL,
    [is_act_email]     BIT              NULL,
    [access_role]      INT              NULL,
    [to_type]          INT              NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Notification] PRIMARY KEY CLUSTERED ([notiId] ASC),
    CONSTRAINT [FK_NotifyInbox_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);










GO
CREATE NONCLUSTERED INDEX [idx_NotifyInbox_subject]
    ON [dbo].[NotifyInbox]([subject] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_NotifyInbox_source_ref]
    ON [dbo].[NotifyInbox]([source_ref] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_NotifyInbox_isPublish]
    ON [dbo].[NotifyInbox]([isPublish] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_NotifyInbox_source_key]
    ON [dbo].[NotifyInbox]([source_key] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_NotifyInbox_n_id]
    ON [dbo].[NotifyInbox]([n_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_NotifyInbox_external_sub]
    ON [dbo].[NotifyInbox]([external_sub] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_NotifyInbox_external_key]
    ON [dbo].[NotifyInbox]([external_key] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_NotifyInbox_createId]
    ON [dbo].[NotifyInbox]([createId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hẹn thời gian gửi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifyInbox', @level2type = N'COLUMN', @level2name = N'Schedule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ten nguoi gui', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifyInbox', @level2type = N'COLUMN', @level2name = N'send_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ten mail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifyInbox', @level2type = N'COLUMN', @level2name = N'send_by';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'externalInfo joson', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifyInbox', @level2type = N'COLUMN', @level2name = N'external_param';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'module', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifyInbox', @level2type = N'COLUMN', @level2name = N'external_key';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0: notify, 1 invite', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotifyInbox', @level2type = N'COLUMN', @level2name = N'notiType';

