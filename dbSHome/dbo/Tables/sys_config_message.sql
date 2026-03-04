CREATE TABLE [dbo].[sys_config_message] (
    [id]       BIGINT           IDENTITY (1, 1) NOT NULL,
    [mod_cd]   NVARCHAR (450)   NULL,
    [code]     NVARCHAR (100)   NOT NULL,
    [messages] NVARCHAR (250)   NOT NULL,
    [level]    INT              NULL,
    [created]  DATETIME         CONSTRAINT [DF_sys_config_message_created] DEFAULT (getdate()) NULL,
    [oid]      UNIQUEIDENTIFIER CONSTRAINT [DF_sys_config_message_oid] DEFAULT (newid()) NOT NULL,
    CONSTRAINT [Pk_sys_config_message] PRIMARY KEY CLUSTERED ([id] ASC, [code] ASC)
);

