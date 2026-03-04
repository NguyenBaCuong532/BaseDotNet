CREATE TABLE [dbo].[PAR_ServiceLivingPrice] (
    [LivingPriceId] INT              IDENTITY (1, 1) NOT NULL,
    [ProjectCd]     NVARCHAR (30)    NULL,
    [Step]          NVARCHAR (50)    NULL,
    [Pos]           INT              NULL,
    [LivingTypeId]  INT              NULL,
    [NumFrom]       INT              NULL,
    [NumTo]         INT              NULL,
    [Price]         DECIMAL (18)     NULL,
    [CalculateType] INT              NULL,
    [free_rt]       FLOAT (53)       NULL,
    [IsFree]        BIT              NULL,
    [IsUsed]        BIT              NULL,
    [TotalNum]      INT              NULL,
    [StartTime]     NVARCHAR (30)    NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_PAR_ServiceLivingPrice_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_PAR_ServiceLivingPrice] PRIMARY KEY CLUSTERED ([LivingPriceId] ASC),
    CONSTRAINT [FK_PAR_ServiceLivingPrice_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
CREATE NONCLUSTERED INDEX [IX_Price_ProjectCd_LivingTypeId_Pos]
    ON [dbo].[PAR_ServiceLivingPrice]([ProjectCd] ASC, [LivingTypeId] ASC, [Pos] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PAR_ServiceLivingPrice_Project_Type]
    ON [dbo].[PAR_ServiceLivingPrice]([ProjectCd] ASC, [LivingTypeId] ASC)
    INCLUDE([NumFrom], [NumTo], [Price]);

