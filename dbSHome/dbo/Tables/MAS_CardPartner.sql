CREATE TABLE [dbo].[MAS_CardPartner] (
    [partner_id]            INT              IDENTITY (1, 1) NOT NULL,
    [partner_cd]            NVARCHAR (50)    NULL,
    [partner_name]          NVARCHAR (50)    NOT NULL,
    [projectCd]             NVARCHAR (20)    NULL,
    [create_dt]             DATETIME         NULL,
    [create_by]             NVARCHAR (100)   NULL,
    [update_dt]             DATETIME         NULL,
    [update_by]             NVARCHAR (100)   NULL,
    [oid]                   UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardPartner_oid] DEFAULT (newid()) NOT NULL,
    [partner_type_id]       INT              NULL,
    [tax_code]              NVARCHAR (50)    NULL,
    [company_phone]         NVARCHAR (50)    NULL,
    [company_email]         NVARCHAR (200)   NULL,
    [contract_start_dt]     DATE             NULL,
    [contract_end_dt]       DATE             NULL,
    [status]                INT              NULL,
    [license_no]            NVARCHAR (100)   NULL,
    [issue_dt]              DATE             NULL,
    [issue_place]           NVARCHAR (255)   NULL,
    [address]               NVARCHAR (500)   NULL,
    [website]               NVARCHAR (255)   NULL,
    [legal_rep_name]        NVARCHAR (255)   NULL,
    [legal_rep_title]       NVARCHAR (255)   NULL,
    [legal_rep_cccd]        NVARCHAR (50)    NULL,
    [legal_rep_issue_dt]    DATE             NULL,
    [legal_rep_issue_place] NVARCHAR (255)   NULL,
    [pic_name]              NVARCHAR (255)   NULL,
    [contact_phone]         NVARCHAR (50)    NULL,
    [contact_email]         NVARCHAR (200)   NULL,
    [partner_status_id]     INT              NOT NULL,
    [tenant_oid]            UNIQUEIDENTIFIER NULL,
    [attachments]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CardPartner] PRIMARY KEY CLUSTERED ([partner_id] ASC),
    CONSTRAINT [FK_MAS_CardPartner_PartnerStatus] FOREIGN KEY ([partner_status_id]) REFERENCES [dbo].[MAS_PartnerStatus] ([status_id]),
    CONSTRAINT [FK_MAS_CardPartner_PartnerType] FOREIGN KEY ([partner_type_id]) REFERENCES [dbo].[MAS_PartnerType] ([partner_type_id]),
    CONSTRAINT [FK_MAS_CardPartner_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_CardPartner_partner_status_id]
    ON [dbo].[MAS_CardPartner]([partner_status_id] ASC);

