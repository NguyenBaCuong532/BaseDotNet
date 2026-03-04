CREATE TABLE [dbo].[bank_codes] (
    [id]                BIGINT           NULL,
    [bank_code]         NVARCHAR (30)    NOT NULL,
    [medium_name_lower] NVARCHAR (50)    NULL,
    [medium_name]       NVARCHAR (50)    NULL,
    [bank_name]         NVARCHAR (250)   NOT NULL,
    [short_name]        NVARCHAR (50)    NOT NULL,
    [url]               NVARCHAR (4000)  NULL,
    [url_type]          NVARCHAR (50)    NULL,
    [is_vietqr]         BIT              NULL,
    [created_at]        DATETIME         CONSTRAINT [DF_bank_codes_created_at] DEFAULT (getdate()) NULL,
    [created_by]        NVARCHAR (50)    NULL,
    [updated_at]        DATETIME         NULL,
    [updated_by]        NVARCHAR (50)    NULL,
    [bank_citad]        NVARCHAR (30)    NULL,
    [Oid]               UNIQUEIDENTIFIER CONSTRAINT [DF_bank_codes_OId] DEFAULT (newid()) NOT NULL,
    [isLoan]            BIT              NULL,
    [tenant_oid]        UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_bank_codes] PRIMARY KEY CLUSTERED ([Oid] ASC),
    CONSTRAINT [FK_bank_codes_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

