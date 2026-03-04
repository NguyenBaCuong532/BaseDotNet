CREATE TABLE [dbo].[CRM_Opportunity] (
    [id]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [opp_cd]         NVARCHAR (50)    NULL,
    [fullName]       NVARCHAR (250)   NULL,
    [phone]          NVARCHAR (30)    NULL,
    [email]          NVARCHAR (150)   NULL,
    [address]        NVARCHAR (350)   NULL,
    [birthday]       INT              NULL,
    [sex]            INT              NULL,
    [projectCd]      NVARCHAR (50)    NULL,
    [need_finacial]  DECIMAL (18)     NULL,
    [need_offer]     NVARCHAR (100)   NULL,
    [need_prod]      NVARCHAR (150)   NULL,
    [need_loan]      INT              NULL,
    [source]         NVARCHAR (100)   NULL,
    [potenial_level] INT              NULL,
    [offer]          NVARCHAR (250)   NULL,
    [feedback]       NVARCHAR (250)   NULL,
    [reviews]        NVARCHAR (350)   NULL,
    [opp_st]         INT              NULL,
    [opp_lst]        DATETIME         NULL,
    [create_by]      NVARCHAR (100)   NULL,
    [create_dt]      DATETIME         NULL,
    [thread_id]      NVARCHAR (150)   NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Opportunity_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Opportunity] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_CRM_Opportunity_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
CREATE NONCLUSTERED INDEX [idx_CRM_Opportunity_phone]
    ON [dbo].[CRM_Opportunity]([phone] ASC);

