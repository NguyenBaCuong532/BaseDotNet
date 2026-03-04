CREATE TABLE [dbo].[request_chat] (
    [id]            UNIQUEIDENTIFIER CONSTRAINT [DF_request_chat_id] DEFAULT (newid()) NOT NULL,
    [visitor_id]    NVARCHAR (50)    NULL,
    [userId]        NVARCHAR (50)    NULL,
    [request_id]    UNIQUEIDENTIFIER NULL,
    [provider_id]   UNIQUEIDENTIFIER NULL,
    [source_type]   NVARCHAR (50)    NULL,
    [token]         NVARCHAR (256)   NULL,
    [department_id] NVARCHAR (50)    NULL,
    [chat_room_id]  NVARCHAR (50)    NULL,
    [is_open]       BIT              NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_request_chat_support] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_request_chat_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [FK_request_chat_user_rocketchat_vistor] FOREIGN KEY ([visitor_id]) REFERENCES [dbo].[user_rocketchat_vistor] ([id])
);

