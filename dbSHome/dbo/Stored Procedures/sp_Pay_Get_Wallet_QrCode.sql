









CREATE procedure [dbo].[sp_Pay_Get_Wallet_QrCode]
	@UserID	nvarchar(450),
	--@WalletCd nvarchar(50)
	@serviceKey nvarchar(50)
as
	begin try		
		 SELECT a.ProviderCd
				,b.ServiceKey
				,c.WalletCd
				,d.QrId
				,e.PosCd
				,upper([ProviderShort])
				+'|' + a.[ProviderCd] +'|' + 'VN|SPAY|' + b.ServiceKey +'|' + e.PosCd 
				+'|' + '02' +'|' + upper(REPLACE(e.PosName,' ',''))
				+'|' + '03'+'|||||' + 'VND' 
				+'||' + upper(REPLACE([dbo].[fChuyenCoDauThanhKhongDau](b.ServiceName),' ','')) 
				+'|' + d.QrKey as QRCode
		  FROM [WAL_Providers] a 
			join [WAL_Services] b on a.ProviderCd = b.ProviderCd 
			join WAL_Profile c on c.BaseCif = a.ProviderCd 
			join WAL_ServicePOS e on e.ServiceKey = b.ServiceKey
			join WAL_QrDuration d on c.WalletCd = d.WalletCd and d.PosCd = e.PosCd
			where d.QrStatus = 1 
				and DATEADD(day,1, d.ExpireDt) > getdate()
				--and c.WalletCd = @WalletCd
				and b.serviceKey like @serviceKey
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_QrCode ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@QrCode ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'QrCode', 'Get', @SessionID, @AddlInfo
	end catch