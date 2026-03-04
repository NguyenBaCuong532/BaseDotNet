CREATE TABLE [dbo].[NotifySentStatusType] (
    [id]               UNIQUEIDENTIFIER CONSTRAINT [DF_NotifySentStatusType_id] DEFAULT (newid()) NOT NULL,
    [push_st]          INT              NULL,
    [sms_st]           INT              NULL,
    [email_st]         INT              NULL,
    [push_st_message]  NVARCHAR (2000)  NULL,
    [sms_st_message]   NVARCHAR (250)   NULL,
    [email_st_message] NVARCHAR (250)   NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_NotifySentStatusType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

