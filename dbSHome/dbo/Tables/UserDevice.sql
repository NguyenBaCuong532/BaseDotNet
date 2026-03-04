CREATE TABLE [dbo].[UserDevice] (
    [id]             UNIQUEIDENTIFIER CONSTRAINT [DF_UserDevice_id] DEFAULT (newid()) NOT NULL,
    [reg_user_id]    BIGINT           NOT NULL,
    [udid]           NVARCHAR (50)    NOT NULL,
    [userId]         UNIQUEIDENTIFIER NOT NULL,
    [deviceName]     NVARCHAR (100)   NOT NULL,
    [deviceProvider] NVARCHAR (150)   NULL,
    [deviceVersion]  NVARCHAR (50)    NULL,
    [playerId]       NVARCHAR (50)    NULL,
    [clientId]       NVARCHAR (50)    NOT NULL,
    [etokenDevice]   BIT              NULL,
    [created_dt]     DATETIME         NULL,
    [update_dt]      DATETIME         NULL,
    [etokenOTP]      NVARCHAR (10)    NULL,
    [etokenDt]       DATETIME         NULL,
    [clientIp]       NVARCHAR (50)    NULL,
    [etokenFail]     INT              NULL,
    [etokenOnAt]     DATETIME         NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_UserDevice] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_UserDevice_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

