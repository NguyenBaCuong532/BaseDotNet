











CREATE procedure [dbo].[sp_Hom_Service_Receipt_ByReceiveId]
	@userId	nvarchar(450),
	@ReceiveId int
as
	begin try

	--1 
	  SELECT [ReceiptId]
		  ,[ReceiptNo]
		  ,convert(nvarchar(10),[ReceiptDt],103) as [ReceiptDate]
		  ,a.custId as CifNo
		  ,a.[ApartmentId]
		  ,a.ReceiveId
		  ,[TranferCd]
		  ,isnull([Object],c.fullName) as [Object]
		  ,a.[Pass_No] as PassNo
		  ,convert(nvarchar(10),a.[Pass_dt],103) as PassDate 
		  ,a.[Pass_Plc] as PassPlc
		  ,a.[Address]
		  ,[Contents]
		  ,[Attach]
		  ,[IsDBCR]
		  ,[Amount]
		  ,[CreatorCd]
		  ,[CreateDate]
		  ,[AccountLeft]
		  ,[AccountRight]
		  ,b.[ProjectCd]
		  ,RoomCode 
		  ,c.FullName
		  ,[dbo].[Num2Text](Amount) AmountText
		  ,ReceiveId
		  ,a.id
	  FROM [dbo].MAS_Service_Receipts a 
		left join  MAS_Apartments b on a.ApartmentId = b.ApartmentId 
		left join MAS_Customers c on a.custId = c.CustId
		WHERE  a.ReceiveId = @ReceiveId
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Receipt_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Document', 'GET', @SessionID, @AddlInfo
	end catch