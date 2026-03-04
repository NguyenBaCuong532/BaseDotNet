CREATE TABLE [dbo].[sys_config_data] (
    [id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [mod_cd]     NVARCHAR (20)    NOT NULL,
    [key_1]      NVARCHAR (100)   NOT NULL,
    [key_2]      NVARCHAR (100)   NOT NULL,
    [key_group]  NVARCHAR (100)   NULL,
    [type_value] INT              NULL,
    [par_desc]   NVARCHAR (200)   NULL,
    [value1]     NVARCHAR (200)   NOT NULL,
    [value2]     INT              NOT NULL,
    [intOrder]   INT              NULL,
    [isUsed]     BIT              NULL,
    [sys_dt]     DATETIME         CONSTRAINT [DF_sys_config_data_sysdt] DEFAULT (getdate()) NOT NULL,
    [par_desc_e] NVARCHAR (200)   NULL,
    [new_id]     BIGINT           NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_sys_config_data_oid] DEFAULT (newid()) NOT NULL,
    CONSTRAINT [PK_sys_config_data] PRIMARY KEY CLUSTERED ([key_1] ASC, [key_2] ASC)
);




GO
