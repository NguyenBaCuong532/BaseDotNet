CREATE TABLE [dbo].[sys_config_list] (
    [id]             BIGINT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [view_grid]      NVARCHAR (100)   NOT NULL,
    [view_type]      INT              NOT NULL,
    [columnField]    NVARCHAR (100)   NOT NULL,
    [data_type]      NVARCHAR (50)    NULL,
    [columnCaption]  NVARCHAR (100)   NULL,
    [columnWidth]    INT              NULL,
    [fieldType]      NVARCHAR (50)    NULL,
    [cellClass]      NVARCHAR (300)   NULL,
    [conditionClass] NVARCHAR (350)   NULL,
    [pinned]         NVARCHAR (50)    NULL,
    [ordinal]        INT              NULL,
    [isUsed]         BIT              NULL,
    [isHide]         BIT              NULL,
    [isMasterDetail] BIT              NULL,
    [isStatusLable]  BIT              NULL,
    [isFilter]       BIT              NULL,
    [sys_dt]         DATETIME         CONSTRAINT [DF_sys_config_list_SysDate] DEFAULT (getdate()) NOT NULL,
    [columnCaptionE] NVARCHAR (100)   NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_sys_config_list_oid] DEFAULT (newid()) NOT NULL,
    CONSTRAINT [PK_sys_config_list] PRIMARY KEY CLUSTERED ([view_grid] ASC, [view_type] ASC, [columnField] ASC)
);




GO
