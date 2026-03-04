CREATE TABLE [dbo].[rocketchat_channel] (
    [id]          VARCHAR (50)     NOT NULL,
    [projectCd]   NVARCHAR (50)    NULL,
    [name]        NVARCHAR (250)   NULL,
    [description] NVARCHAR (250)   NULL,
    [private]     BIT              NULL,
    [read_only]   BIT              NULL,
    [approval]    BIT              NULL,
    [meta_data]   NVARCHAR (MAX)   NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_rocketchat_channel_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_rocketchat_channel] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_rocketchat_channel_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

