CREATE TABLE [dbo].[trans_response_klb] (
    [id]             UNIQUEIDENTIFIER CONSTRAINT [DF_trans_response_klb_id] DEFAULT (newid()) NOT NULL,
    [success]        BIT              NULL,
    [interBankTrace] NVARCHAR (100)   NULL,
    [virtualAccount] NVARCHAR (100)   NULL,
    [actualAccount]  NVARCHAR (100)   NULL,
    [fromBin]        NVARCHAR (100)   NULL,
    [fromAccount]    NVARCHAR (100)   NULL,
    [amount]         DECIMAL (18)     NULL,
    [statusCode]     NVARCHAR (100)   NULL,
    [txnNumber]      NVARCHAR (100)   NULL,
    [transferDesc]   NVARCHAR (100)   NULL,
    [time]           NVARCHAR (50)    NULL,
    [created]        DATETIME         NULL,
    [created_by]     NVARCHAR (50)    NULL,
    [rc_count]       INT              NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_trans_response_klb_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

