CREATE TABLE [dbo].[UserMeta] (
    [id]           UNIQUEIDENTIFIER CONSTRAINT [DF_UserMeta_id] DEFAULT (newid()) NOT NULL,
    [doc_type]     NVARCHAR (30)    NOT NULL,
    [doc_sub_type] NVARCHAR (30)    NULL,
    [reg_userId]   BIGINT           NULL,
    [custId]       NVARCHAR (100)   NULL,
    [meta_url]     NVARCHAR (450)   NOT NULL,
    [meta_name]    NVARCHAR (200)   NULL,
    [meta_type]    NVARCHAR (50)    NULL,
    [meta_note]    NVARCHAR (250)   NULL,
    [mkr_id]       NVARCHAR (100)   NOT NULL,
    [mkr_dt]       DATETIME         NULL,
    [status]       CHAR (1)         NULL,
    [sysdate]      DATETIME         CONSTRAINT [DF_UserMeta_sysdate] DEFAULT (getdate()) NULL,
    [meta_code]    NVARCHAR (50)    NULL,
    [meta_size]    INT              NULL,
    [regOid]       UNIQUEIDENTIFIER NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_UserMeta_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

