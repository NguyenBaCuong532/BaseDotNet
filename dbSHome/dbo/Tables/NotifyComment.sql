CREATE TABLE [dbo].[NotifyComment] (
    [commentId]  UNIQUEIDENTIFIER CONSTRAINT [DF__NotifyCom__comme__0BD1B136] DEFAULT (newid()) NOT NULL,
    [notiId]     INT              NOT NULL,
    [parrentId]  UNIQUEIDENTIFIER NULL,
    [comments]   NVARCHAR (400)   NOT NULL,
    [commentDt]  DATETIME         CONSTRAINT [DF__NotifyCom__comme__0CC5D56F] DEFAULT (getdate()) NULL,
    [user_id]    NVARCHAR (100)   NULL,
    [usser_name] NVARCHAR (100)   NULL,
    [auth_st]    INT              NULL,
    [auth_dt]    DATETIME         NULL,
    [auth_id]    NVARCHAR (100)   NULL,
    [n_id]       UNIQUEIDENTIFIER NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_NotifyComment] PRIMARY KEY CLUSTERED ([commentId] ASC),
    CONSTRAINT [FK_NotifyComment_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

