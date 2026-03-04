CREATE TABLE [dbo].[audit_email_sms] (
    [receiveIds] NVARCHAR (MAX)   NULL,
    [sysdt]      DATETIME         CONSTRAINT [DF_audit_email_sms_sysdt] DEFAULT (getdate()) NULL,
    [userId]     NVARCHAR (50)    NULL,
    [projectCd]  NVARCHAR (2000)  NULL,
    [type]       NVARCHAR (50)    NULL,
    [n_id]       NVARCHAR (50)    NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_audit_email_sms_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_audit_email_sms_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

