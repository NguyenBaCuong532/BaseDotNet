CREATE TYPE [dbo].[NotifySentStatusType] AS TABLE (
    [id]               UNIQUEIDENTIFIER NULL,
    [push_st]          INT              NULL,
    [sms_st]           INT              NULL,
    [email_st]         INT              NULL,
    [push_st_message]  NVARCHAR (2000)  NULL,
    [sms_st_message]   NVARCHAR (250)   NULL,
    [email_st_message] NVARCHAR (250)   NULL);

