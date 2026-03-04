CREATE TABLE [dbo].[CRM_Attend_Track] (
    [track_id]          BIGINT           IDENTITY (1, 1) NOT NULL,
    [attend_cd]         NVARCHAR (10)    NULL,
    [contactName]       NVARCHAR (250)   NULL,
    [Phone]             NVARCHAR (30)    NULL,
    [Email]             NVARCHAR (200)   NULL,
    [Note]              NVARCHAR (MAX)   NULL,
    [child_name]        NVARCHAR (250)   NULL,
    [child_birthday]    DATETIME         NULL,
    [learned_maplebear] BIT              NULL,
    [num_of_attend]     INT              NULL,
    [ReferralCode]      NVARCHAR (20)    NULL,
    [qrcode_url]        NVARCHAR (400)   NULL,
    [Source]            NVARCHAR (200)   NULL,
    [Createdate]        DATETIME         NULL,
    [arrived_st]        BIT              NULL,
    [arrived_dt]        DATETIME         NULL,
    [arrived_id]        NVARCHAR (100)   NULL,
    [oid]               UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Attend_Track_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]        UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Attend_Track] PRIMARY KEY CLUSTERED ([track_id] ASC),
    CONSTRAINT [FK_CRM_Attend_Track_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

