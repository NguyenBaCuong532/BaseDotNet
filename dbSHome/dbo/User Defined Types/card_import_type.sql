CREATE TYPE [dbo].[card_import_type] AS TABLE (
    [seq]         INT            NULL,
    [serial]      VARCHAR (50)   NULL,
    [code]        NVARCHAR (50)  NULL,
    [hex]         VARCHAR (50)   NULL,
    [projectName] NVARCHAR (250) NULL,
    [lotNumber]   NVARCHAR (50)  NULL);

