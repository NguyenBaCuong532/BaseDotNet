CREATE TABLE [dbo].[rocketchat_channel_join_request] (
    [id]              UNIQUEIDENTIFIER CONSTRAINT [DF_rocketchat_channel_join_request_id] DEFAULT (newid()) NOT NULL,
    [channel_id]      VARCHAR (50)     NOT NULL,
    [user_id]         UNIQUEIDENTIFIER NOT NULL,
    [approval_status] INT              CONSTRAINT [DF_rocketchat_channel_join_request_approval_status] DEFAULT ((0)) NULL,
    [created]         DATETIME         CONSTRAINT [DF_rocketchat_channel_join_request_created] DEFAULT (getdate()) NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_rocketchat_channel_join_request] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_rocketchat_channel_join_request_rocketchat_channel] FOREIGN KEY ([channel_id]) REFERENCES [dbo].[rocketchat_channel] ([id]),
    CONSTRAINT [FK_rocketchat_channel_join_request_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

