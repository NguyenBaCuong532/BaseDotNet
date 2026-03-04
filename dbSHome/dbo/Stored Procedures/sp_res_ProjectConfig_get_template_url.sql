CREATE PROCEDURE [dbo].[sp_res_ProjectConfig_get_template_url]
	@userId	nvarchar(450) = null ,
	@receiveId int =   162303
AS
BEGIN
    SET NOCOUNT ON;
	declare @ApartmentId int 
	declare @ProjectCd nvarchar(50) = ''
	set @ApartmentId = (select top 1 ApartmentId from MAS_Service_ReceiveEntry where ReceiveId = @receiveId)
	set @ProjectCd = (select top 1 isnull(projectCd,'01') from MAS_Apartments where ApartmentId = @ApartmentId)
  
    -- Lấy file_url trong bảng cấu hình
    SELECT TOP 1 file_url
    FROM meta_info b JOIN par_project_config a 
			ON b.sourceOid =  TRY_CONVERT(uniqueidentifier, 
                    CASE 
                        WHEN a.config_value IS NULL OR LTRIM(RTRIM(a.config_value)) = '' 
                            THEN a.config_value_default
                        ELSE a.config_value
                    END)
    WHERE config_code = 'file_mau_thong_bao_phi'
      AND project_code = @ProjectCd 
END