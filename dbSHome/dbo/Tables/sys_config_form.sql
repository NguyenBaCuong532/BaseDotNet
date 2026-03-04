CREATE TABLE [dbo].[sys_config_form] (
    [id]            BIGINT           IDENTITY (1, 1) NOT NULL,
    [table_name]    NVARCHAR (100)   NOT NULL,
    [field_name]    NVARCHAR (100)   NOT NULL,
    [view_type]     INT              NOT NULL,
    [data_type]     NVARCHAR (50)    NOT NULL,
    [ordinal]       INT              NULL,
    [group_cd]      NVARCHAR (50)    NULL,
    [columnLabel]   NVARCHAR (100)   NULL,
    [columnLabelE]  NVARCHAR (100)   NULL,
    [columnTooltip] NVARCHAR (300)   NULL,
    [columnDefault] NVARCHAR (300)   NULL,
    [columnClass]   NVARCHAR (50)    NULL,
    [columnType]    NVARCHAR (50)    NULL,
    [columnObject]  NVARCHAR (500)   NULL,
    [isVisiable]    BIT              NULL,
    [isSpecial]     BIT              NULL,
    [isRequire]     BIT              NULL,
    [isDisable]     BIT              NULL,
    [IsEmpty]       BIT              NULL,
    [columnDisplay] NVARCHAR (300)   NULL,
    [sys_dt]        DATETIME         CONSTRAINT [DF_sys_config_form_sysdt] DEFAULT (getdate()) NOT NULL,
    [isIgnore]      BIT              NULL,
    [is_active]     BIT              CONSTRAINT [DF_sys_config_form_is_use] DEFAULT ((1)) NULL,
    [new_id]        BIGINT           NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_sys_config_form_oid] DEFAULT (newid()) NOT NULL,
    CONSTRAINT [PK_sys_config_form] PRIMARY KEY CLUSTERED ([table_name] ASC, [field_name] ASC, [view_type] ASC)
);






GO
