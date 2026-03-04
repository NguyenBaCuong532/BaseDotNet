CREATE TABLE [dbo].[rocketchat_channel_member] (
    [id]         UNIQUEIDENTIFIER CONSTRAINT [DF_rocketchat_channel_member_id] DEFAULT (newid()) NOT NULL,
    [channel_id] VARCHAR (50)     NULL,
    [user_id]    UNIQUEIDENTIFIER NOT NULL,
    [status]     INT              NULL,
    [created]    DATETIME         CONSTRAINT [DF_rocketchat_channel_member_created] DEFAULT (getdate()) NULL,
    [updated]    DATETIME         NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_rocketchat_channel_member] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_rocketchat_channel_member_rocketchat_channel] FOREIGN KEY ([channel_id]) REFERENCES [dbo].[rocketchat_channel] ([id]),
    CONSTRAINT [FK_rocketchat_channel_member_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

