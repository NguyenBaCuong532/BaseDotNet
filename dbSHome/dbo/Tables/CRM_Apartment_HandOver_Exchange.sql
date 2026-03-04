CREATE TABLE [dbo].[CRM_Apartment_HandOver_Exchange] (
    [ExchangeId]       BIGINT           IDENTITY (1, 1) NOT NULL,
    [HandOverId]       BIGINT           NULL,
    [HandOverDetailId] BIGINT           NULL,
    [Title]            NVARCHAR (256)   NULL,
    [UserAssign]       NVARCHAR (500)   NULL,
    [DepartmentCd]     NVARCHAR (50)    NULL,
    [StatusType]       INT              NULL,
    [UserAdminAssign]  NVARCHAR (50)    NULL,
    [WorkStatusId]     INT              NULL,
    [TeamType]         INT              NULL,
    [TeamName]         NVARCHAR (100)   NULL,
    [StartDate]        DATETIME         NULL,
    [EndDate]          DATETIME         NULL,
    [TotalTime]        INT              NULL,
    [Note]             NVARCHAR (500)   NULL,
    [PercentDone]      INT              NULL,
    [Created]          DATETIME         NULL,
    [CreatedBy]        NVARCHAR (50)    NULL,
    [Modified]         DATETIME         NULL,
    [ModifiedBy]       NVARCHAR (50)    NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Apartment_HandOver_Exchange_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Apartment_HandOver_Exchange] PRIMARY KEY CLUSTERED ([ExchangeId] ASC),
    CONSTRAINT [FK_CRM_Apartment_HandOver_Exchange_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE TRIGGER [dbo].[trg_CRM_Apartment_HandOver_Exchange_update_CRM_Apartment_HandOver_Detail] 
   ON  dbo.CRM_Apartment_HandOver_Exchange
   FOR INSERT,UPDATE
AS 
BEGIN
	
	SET NOCOUNT ON;
	declare @total int
	declare @dem int

	set @total = (select count(*) from CRM_Apartment_HandOver_Exchange a left join inserted b on a.HandOverDetailId = b.HandOverDetailId)
	set @dem = (select count(*) from CRM_Apartment_HandOver_Exchange a left join inserted b on a.HandOverDetailId = b.HandOverDetailId and a.WorkStatusId <> 3)

	if (@total = @dem)
		begin
			update t set t.PercentDone = 100
			from CRM_Apartment_HandOver_Detail t join inserted b on t.HandOverDetailId = b.HandOverDetailId
		end
	else
		begin
			update t set t.PercentDone = round(@dem/@total,0)
			from CRM_Apartment_HandOver_Detail t join inserted b on t.HandOverDetailId = b.HandOverDetailId
		end
	update t set t.PercentDone = 100
	from CRM_Apartment_HandOver_Exchange t inner join inserted b on t.ExchangeId = b.ExchangeId and b.WorkStatusId = 3
	update t set t.PercentDone = 0
	from CRM_Apartment_HandOver_Exchange t inner join inserted b on t.ExchangeId = b.ExchangeId and (b.WorkStatusId = 1)-- or b.WorkStatusId = 2)


END
GO
CREATE TRIGGER [dbo].[trg_CRM_Apartment_HandOver_Exchange_delete_CRM_Apartment_HandOver_Detail] 
   ON  dbo.CRM_Apartment_HandOver_Exchange
   FOR DELETE
AS 
BEGIN
	
	SET NOCOUNT ON;
	declare @total decimal(18,1)
	declare @dem decimal(18,1)

	set @total = (select count(*) from CRM_Apartment_HandOver_Exchange a left join deleted b on a.HandOverDetailId = b.HandOverDetailId)
	set @dem = (select count(*) from CRM_Apartment_HandOver_Exchange a left join deleted b on a.HandOverDetailId = b.HandOverDetailId and a.WorkStatusId <> 3)

	if (@total = @dem)
		begin
			update t set t.PercentDone = 100
			from CRM_Apartment_HandOver_Detail t join deleted b on t.HandOverDetailId = b.HandOverDetailId
		end
	else
		begin
			update t set t.PercentDone = cast((@dem/@total)*100 as int)
			from CRM_Apartment_HandOver_Detail t join deleted b on t.HandOverDetailId = b.HandOverDetailId
		end

END