using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.API.Attributes;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.Version2.Settings
{

    /// <summary>
    /// Apartment Controller
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/common/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class CommonController : UniController
    {
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly ICommonService _commService;
        private readonly NotifySetting _notifySettings;
        /// <summary>
        /// Initializes a new instance of the <see cref="CommonController"/> class.
        /// </summary>
        /// <param name="apartmentService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="mapper"></param>
        public CommonController(
            ICommonService apartmentService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IMapper mapper) : base(appSettings, logger)
        {
            _commService = apartmentService;
            _notifySettings = appSettings.Value.Notify;
        }

        #region Apartment
        /// <summary>
        /// GetFilterForm - Lấy cấu hình filter của manager
        /// </summary>
        /// <param name="filterName"></param>
        /// <returns></returns>
        [HttpGet("{filterName}")]
        public async Task<IActionResult> GetFilterForm(string filterName)
        {
            var rs = await _commService.GetCommonFilterInfo(filterName);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }
        /// <summary>
        /// SetCommonFilterDraft Tạo bản nháp filter
        /// </summary>
        /// <param name="draft"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<CommonViewInfo>> SetCommonFilterDraft([FromBody] CommonViewInfo draft)
        {
            if (!this.ModelState.IsValid)
            {
                return GetErrorResponse<CommonViewInfo>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _commService.SetCommonFilterDraft(draft);
            return GetResponse<CommonViewInfo>(ApiResult.Success, result);
        }
        /// <summary>
        /// GetObjectList - Lấy object config data 
        /// </summary>
        /// <param name="objKey">objKey là Receive,Rent,setupStatus</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetObjectList([FromQuery] string objKey, [FromQuery] string all)
        {
            var result = await _commService.GetObjectList(objKey, all);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetObjectClass
        /// </summary>
        /// <param name="objKey"></param>
        /// <param name="all"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetObjectClass([FromQuery] string objKey, [FromQuery] string all)
        {
            var result = await _commService.GetObjectClass(objKey, all);
            return GetResponse(ApiResult.Success, result);
        }


        #endregion
        /// <summary>
        /// GetCardTypes - Lấy ds loại thẻ
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<IActionResult> GetCardTypes()
        {
            IEnumerable<CommonValue> rs = await _commService.GetCardTypes();
            var rp = GetResponse(UNI.Model.Api.ApiResult.Success, rs);
            return Ok(rp);
        }

        /// <summary>
        /// GetNotifyList - Lấy ds thông báo
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetNotifyList()
        {
            var result = await _commService.GetNotifyList(_notifySettings.ExternalKey);
            return GetResponse(ApiResult.Success, result);
        }

        //[HttpGet]
        //public async Task<BaseResponse<List<CommonValue>>> GetProjectList(string userId, bool? isAll)
        //{
        //    var result = await _commService.GetProjectList(userId, isAll);
        //    return GetResponse(ApiResult.Success, result);
        //}
        /// <summary>
        /// GetCommonlist - get list danh mục chung
        /// </summary>
        /// <param name="isfilter">Thêm giá trị mặc định (-1 : tất cả)</param>
        /// <param name="tableName">Tên bảng cần lấy dữ liệu</param>
        /// <param name="columnName">Tên cột  cần lấy - tương ứng name</param>
        /// <param name="columnId">Tên cột cần lấy - tương ứng value</param>
        /// <param name="columnParent">Tên cột cần so sánh giá trị</param>
        /// <param name="valueParent">Tên cột giá trị cần so sánh</param>
        /// <param name="colSortOrder">Tên cột cần sắp xếp thứ tự cho kết quả cuối cùng</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetCommonList([FromQuery] bool isfilter,
            [FromQuery] string tableName, [FromQuery] string columnName, [FromQuery] string columnId,
            [FromQuery] string columnParent, [FromQuery] string valueParent, [FromQuery] string colSortOrder)
        {
            var result = await _commService.GetCommonList(isfilter, tableName, columnName, columnId, columnParent, valueParent, colSortOrder);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetBuildingList - Lấy ds nhà cung cấp theo loại HĐ
        /// </summary>
        /// <param name="ContractTypeId">id loại HĐ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetServiceProviderList([FromQuery] int? ContractTypeId)
        {
            var result = await _commService.GetServiceProviderList(ContractTypeId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetFamilyMemberList - Lấy ds thành viên trong căn hộ
        /// </summary>
        /// <param name="ApartmentId">id loại HĐ</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetFamilyMemberList(int? ApartmentId)
        {
            var result = await _commService.GetFamilyMemberList(ApartmentId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetProjectList - Lấy ds dự án
        /// </summary>
        /// <param name="isAll">Có lấy thêm giá trị tất cả ngoài tên dự án thực tế ?</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetProjectList(bool? isAll)
        {
            var result = await _commService.GetProjectList(isAll);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetProjectList - Lấy ds dự án 1
        /// </summary>
        /// <param name="isAll">Có lấy thêm giá trị tất cả ngoài tên dự án thực tế ?</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetProjectList1(bool? isAll)
        {
            var result = await _commService.GetProjectList1(isAll);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetProjectList - Lấy ds dự án
        /// </summary>
        /// <param name="isAll">Có lấy thêm giá trị tất cả ngoài tên dự án thực tế ?</param>
        /// <returns></returns>
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<List<CommonValue>>> GetProjectListForOutSide(bool? isAll)
        {
            var result = await _commService.GetProjectListForOutSide(isAll);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Get Request - trạng thái yêu cầu hỗ trợ
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetRequestStatusList()
        {
            var result = await _commService.GetObjectList("request_st", "");
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetBuildingList - Lấy ds tòa nhà theo mã dự án
        /// </summary>
        /// <param name="projectCd">mã dự án</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetBuildingList([FromQuery] string projectCd, [FromQuery] bool? isAll)
        {
            var result = await _commService.GetBuildingList(projectCd, isAll);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetBuildingList - Lấy ds tòa nhà theo mã dự án
        /// </summary>
        /// <param name="buildingCd">mã dự án</param>
        /// <param name="isAll"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetAreaList([FromQuery] string buildingCd, [FromQuery] string projectCd, [FromQuery] bool? isAll)
        {
            var result = await _commService.GetAreaList(buildingCd, projectCd, isAll);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetFloorList - Lấy ds tầng theo mã tòa nhà hoặc buildingOid
        /// </summary>
        /// <param name="buildingCd">mã tòa nhà (backward compatible)</param>
        /// <param name="buildingOid">oid tòa nhà (ưu tiên nếu có)</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetFloorList([FromQuery] string buildingCd, [FromQuery] Guid? buildingOid = null)
        {
            var result = await _commService.GetFloorList(buildingCd, buildingOid);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// GetFloorList - Lấy ds tầng thoe mã tòa nhà
        /// </summary>
        /// <param name="buildingCd">mã tòa nhà</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetElevatorFloorList([FromQuery] string projectCd, [FromQuery] string areaCd, [FromQuery] string buildZone)
        {
            var result = await _commService.GetElevatorFloorList(projectCd, areaCd, buildZone);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// GetRoomList - Lấy ds phòng theo tầng, tòa nhà (hỗ trợ buildingOid, floorOid)
        /// </summary>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetRoomList([FromQuery] string buildingCd, [FromQuery] string floorNo, [FromQuery] Guid? buildingOid = null, [FromQuery] Guid? floorOid = null)
        {
            var result = await _commService.GetRoomList(buildingCd, floorNo, buildingOid, floorOid);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetRoomList2 - Lấy ds căn hộ theo tòa nhà, dự án (hỗ trợ buildingOid, floorOid, apartOid)
        /// </summary>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetRoomList2([FromQuery] string projectCd,
            [FromQuery] string buildingCd, [FromQuery] string floorNo, [FromQuery] int? apartmentId = null, [FromQuery] string filter = null,
            [FromQuery] Guid? buildingOid = null, [FromQuery] Guid? floorOid = null, [FromQuery] Guid? apartOid = null)
        {
            var result = await _commService.GetRoomList2(projectCd, buildingCd, floorNo, apartmentId, filter, buildingOid, floorOid, apartOid);
            return GetResponse(ApiResult.Success, result);
        }

        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetRoomList3([FromQuery] string projectCd, [FromQuery] string Oids, [FromQuery] string filter)
        {
            var result = await _commService.GetRoomList3(projectCd, Oids, filter);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Danh sách mã các ngân hàng
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetBankCodes(string filter = null)
        {
            var result = await _commService.GetBankCodes(filter);
            return GetResponse(ApiResult.Success, result);
        }
    }
}