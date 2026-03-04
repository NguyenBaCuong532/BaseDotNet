CREATE TABLE [dbo].[UserInfo] (
    [reg_userId]        BIGINT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [userId]            UNIQUEIDENTIFIER NULL,
    [userType]          INT              NULL,
    [userManager]       BIT              NULL,
    [custId]            NVARCHAR (100)   NULL,
    [cif_no]            NVARCHAR (20)    NULL,
    [referralCd]        NVARCHAR (20)    NULL,
    [avatarUrl]         NVARCHAR (350)   NULL,
    [loginName]         NVARCHAR (50)    NOT NULL,
    [loginType]         INT              NULL,
    [LoginId]           NVARCHAR (150)   NULL,
    [nickName]          NVARCHAR (250)   NULL,
    [fullName]          NVARCHAR (250)   NULL,
    [cntry_reg]         NVARCHAR (20)    NULL,
    [phoneF]            NVARCHAR (20)    NULL,
    [phone]             NVARCHAR (20)    NULL,
    [email]             NVARCHAR (200)   NULL,
    [sex]               BIT              NULL,
    [birthday]          DATETIME         NULL,
    [idcard_type]       INT              NULL,
    [idcard_no]         NVARCHAR (50)    NULL,
    [idcard_issue_dt]   DATETIME         NULL,
    [idcard_issue_plc]  NVARCHAR (250)   NULL,
    [idcard_expire_dt]  DATETIME         NULL,
    [res_add]           NVARCHAR (250)   NULL,
    [res_city]          NVARCHAR (250)   NULL,
    [res_cntry]         NVARCHAR (20)    NULL,
    [trad_add]          NVARCHAR (350)   NULL,
    [tax_code]          NVARCHAR (30)    NULL,
    [marial_st]         INT              NULL,
    [bank_name]         NVARCHAR (200)   NULL,
    [bank_acc_no]       NVARCHAR (50)    NULL,
    [bank_acc_name]     NVARCHAR (250)   NULL,
    [bank_branch]       NVARCHAR (250)   NULL,
    [bank_code]         NVARCHAR (30)    NULL,
    [email_verified]    INT              NULL,
    [idcard_verified]   INT              NULL,
    [residen_linked]    BIT              NULL,
    [staff_linked]      BIT              NULL,
    [fb_linked]         BIT              NULL,
    [fb_id]             NVARCHAR (100)   NULL,
    [fb_name]           NVARCHAR (250)   NULL,
    [fb_email]          NVARCHAR (250)   NULL,
    [fb_birthday]       NVARCHAR (20)    NULL,
    [fb_gender]         NVARCHAR (20)    NULL,
    [fb_token]          NVARCHAR (450)   NULL,
    [invited_by]        NVARCHAR (20)    NULL,
    [invited_at]        DATETIME         NULL,
    [agreed_st]         BIT              NULL,
    [agreed_dt]         DATETIME         NULL,
    [lock_st]           BIT              NULL,
    [lock_dt]           DATETIME         NULL,
    [last_st]           BIT              NULL,
    [last_dt]           DATETIME         NULL,
    [gr_rank]           INT              NULL,
    [u_rank]            INT              NULL,
    [work_st]           INT              NULL,
    [verifyType]        INT              NULL,
    [verifyOtp]         INT              NULL,
    [verifyCode]        NVARCHAR (10)    NULL,
    [recognition_rt]    FLOAT (53)       NULL,
    [verify_profile]    BIT              NULL,
    [sys_time_stamp]    DATETIME         CONSTRAINT [DF_UserInfo_sys_dt] DEFAULT (getdate()) NULL,
    [crm_id]            NVARCHAR (30)    NULL,
    [crm_lead_id]       NVARCHAR (30)    NULL,
    [origin_add]        NVARCHAR (250)   NULL,
    [ekyc_verified]     INT              NULL,
    [face_id]           NVARCHAR (100)   NULL,
    [verify_dt]         DATETIME         NULL,
    [verify_by]         NVARCHAR (100)   NULL,
    [phone_confirmed]   BIT              NULL,
    [email_confirmed]   BIT              NULL,
    [token_code]        UNIQUEIDENTIFIER NULL,
    [token_expire]      DATETIME         NULL,
    [active_dt]         DATETIME         NULL,
    [regOid]            UNIQUEIDENTIFIER CONSTRAINT [DF_UserInfo_regOid] DEFAULT (newid()) NOT NULL,
    [rocketchat_userid] NVARCHAR (50)    NULL,
    [created_dt]        DATETIME         NULL,
    [modified_dt]       DATETIME         NULL,
    [oid]               UNIQUEIDENTIFIER CONSTRAINT [DF_UserInfo_oid] DEFAULT (newid()) NOT NULL,
    [lastUserId]        UNIQUEIDENTIFIER NULL,
    [tenant_oid]        UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_UserInfo] PRIMARY KEY CLUSTERED ([reg_userId] ASC),
    CONSTRAINT [FK_UserInfo_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [Constraint_UserInfo_loginName] UNIQUE NONCLUSTERED ([loginName] ASC)
);










GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0: từ số đt, 1 từ tên login, 2 từ fb, 3 từ gg mail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserInfo', @level2type = N'COLUMN', @level2name = N'loginType';


GO
CREATE NONCLUSTERED INDEX [ix_UserInfo_userid]
    ON [dbo].[UserInfo]([userId] ASC) WHERE ([userid] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_UserInfo_UserId_inc]
    ON [dbo].[UserInfo]([userId] ASC)
    INCLUDE([custId], [loginName], [last_dt], [last_st]);

