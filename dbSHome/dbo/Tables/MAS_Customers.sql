CREATE TABLE [dbo].[MAS_Customers] (
    [CustId]      NVARCHAR (50)    NOT NULL,
    [Cif_No]      NVARCHAR (50)    NULL,
    [FullName]    NVARCHAR (250)   NULL,
    [FirstName]   NVARCHAR (100)   NULL,
    [LastName]    NVARCHAR (150)   NULL,
    [AvatarUrl]   NVARCHAR (350)   NULL,
    [IsSex]       BIT              NULL,
    [Birthday]    DATETIME         NULL,
    [RelationId]  INT              NULL,
    [Phone]       NVARCHAR (50)    NULL,
    [Phone2]      NVARCHAR (30)    NULL,
    [Email]       NVARCHAR (150)   NULL,
    [Email2]      NVARCHAR (150)   NULL,
    [Pass_No]     NVARCHAR (50)    NULL,
    [Pass_Dt]     DATE             NULL,
    [Pass_Plc]    NVARCHAR (150)   NULL,
    [Address]     NVARCHAR (350)   NULL,
    [ProvinceCd]  NVARCHAR (30)    NULL,
    [IsForeign]   BIT              NULL,
    [CountryCd]   NVARCHAR (30)    NULL,
    [IsContact]   BIT              NULL,
    [IsEmployee]  BIT              NULL,
    [sysDate]     DATETIME         CONSTRAINT [DF_MAS_Customers_sysDate] DEFAULT (getdate()) NULL,
    [IsAdmin]     BIT              NULL,
    [ApartmentId] INT              NULL,
    [IsHost]      BIT              NULL,
    [Auth_St]     BIT              NULL,
    [Auth_Dt]     DATETIME         NULL,
    [Auth_Id]     NVARCHAR (50)    NULL,
    [rowguid]     UNIQUEIDENTIFIER CONSTRAINT [MSmerge_df_rowguid_517AC42BAF3547D4BA07425D5955E568] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [RoomCodes]   NVARCHAR (150)   NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Customers_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Customers] PRIMARY KEY CLUSTERED ([CustId] ASC),
    CONSTRAINT [FK_MAS_Customers_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [IX_MAS_Customers_Phone_CifNo_INC_CustId]
    ON [dbo].[MAS_Customers]([Phone] ASC, [Cif_No] ASC)
    INCLUDE([CustId]) WITH (DATA_COMPRESSION = ROW);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Customers_IsForeign]
    ON [dbo].[MAS_Customers]([IsForeign] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Customers_FullName]
    ON [dbo].[MAS_Customers]([FullName] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Customers_Pass_No]
    ON [dbo].[MAS_Customers]([Pass_No] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Customers_email]
    ON [dbo].[MAS_Customers]([Email] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Customers_phone]
    ON [dbo].[MAS_Customers]([Phone] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Customers_cif_no]
    ON [dbo].[MAS_Customers]([Cif_No] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [index_CustomerId]
    ON [dbo].[MAS_Customers]([CustId] ASC);


GO

CREATE TRIGGER [dbo].[trg_mas_customers_update] 
   ON  [dbo].[MAS_Customers]
   FOR INSERT,UPDATE
AS 
BEGIN
	
	SET NOCOUNT ON;
			
			IF ( UPDATE (CustId) and exists(select 1 from Inserted where CustId = '' or CustId is null))  
			BEGIN  
				RAISERROR (50009, 16, 10)  
			END;  

END
GO

CREATE TRIGGER [dbo].[trg_mas_customers_delete] 
   ON  [dbo].[MAS_Customers]
   FOR DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--	SET NOCOUNT ON;
	
		INSERT INTO [dbo].[MAS_Customers_Save]
			   ([CustId]
			   ,[Cif_No]
			   ,[FullName]
			   ,[FirstName]
			   ,[LastName]
			   ,[AvatarUrl]
			   ,[IsSex]
			   ,[Birthday]
			   ,[RelationId]
			   ,[Phone]
			   ,[Phone2]
			   ,[Email]
			   ,[Email2]
			   ,[Pass_No]
			   ,[Pass_Dt]
			   ,[Pass_Plc]
			   ,[Address]
			   ,[ProvinceCd]
			   ,[IsForeign]
			   ,[CountryCd]
			   ,[IsContact]
			   ,[IsEmployee]
			   ,[sysDate]
			   ,[IsAdmin]
			   ,[ApartmentId]
			   ,[IsHost]
			   ,[Auth_St]
			   ,[Auth_Dt]
			   ,[Auth_Id]
			   ,[saveDate])
		SELECT [CustId]
			  ,[Cif_No]
			  ,[FullName]
			  ,[FirstName]
			  ,[LastName]
			  ,[AvatarUrl]
			  ,[IsSex]
			  ,[Birthday]
			  ,[RelationId]
			  ,[Phone]
			  ,[Phone2]
			  ,[Email]
			  ,[Email2]
			  ,[Pass_No]
			  ,[Pass_Dt]
			  ,[Pass_Plc]
			  ,[Address]
			  ,[ProvinceCd]
			  ,[IsForeign]
			  ,[CountryCd]
			  ,[IsContact]
			  ,[IsEmployee]
			  ,[sysDate]
			  ,[IsAdmin]
			  ,[ApartmentId]
			  ,[IsHost]
			  ,[Auth_St]
			  ,[Auth_Dt]
			  ,[Auth_Id]
			  ,getdate()
		  FROM  DELETED t2 
	

END
GO
CREATE NONCLUSTERED INDEX [IX_MAS_Customers_CustId]
    ON [dbo].[MAS_Customers]([CustId] ASC)
    INCLUDE([Cif_No]);

