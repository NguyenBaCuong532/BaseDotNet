using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.API.Filters;
using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.API.Controllers.Version2.Aparment
{

    /// <summary>
    /// Apartment Controller
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/familymember/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class FamilyMemberController : UniController
    {
        /// <summary>
        /// The investment service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        private readonly IFamilyMemberService _apartmentService;

        /// <summary>
        /// Initializes a new instance of the <see cref="ApartmentController"/> class.
        /// </summary>
        /// <param name="apartmentService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public FamilyMemberController(IFamilyMemberService apartmentService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _apartmentService = apartmentService;
        }

        #region FamilyMember
        /// <summary>
        /// GetFamilyMember
        /// </summary>
        /// <param name="ApartmentId">ID căn hộ (long) - backward compatible</param>
        /// <param name="apartOid">Mã định danh căn hộ (UUID) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<IActionResult> GetFamilyMember([FromQuery] long? ApartmentId, [FromQuery] Guid? apartOid)
        {
            var rs = await _apartmentService.GetFamilyMember(ApartmentId ?? 0, apartOid);
            var rp = GetResponse(ApiResult.Success, rs);
            return Ok(rp);
        }
        /// <summary>
        /// GetFamilyMemberPageAsync - Danh sách thành viên trong căn hộ
        /// </summary>
        /// <param name = "query" ></ param >
        /// < returns ></ returns >
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetFamilyMemberPage([FromQuery] FamilyMemberRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _apartmentService.GetFamilyMemberPage(query);
                var rp = GetResponse(ApiResult.Success, rs);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CommonDataPage>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// GetApartmentFamilyMemberChangHostInfoAsync - Xem chi tiết thông tin chủ hộ
        /// </summary>
        /// <param name="CustId">Mã khách hàng</param>
        /// <param name="ApartmentId">ID căn hộ (int) - backward compatible</param>
        /// <param name="apartOid">Mã định danh căn hộ (UUID) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<FamilyMemberChangeHostInfo>> GetFamilyMemberChangHost([FromQuery] string CustId, [FromQuery] int? ApartmentId, [FromQuery] Guid? apartOid)
        {
            try
            {
                var rs = await _apartmentService.GetFamilyMemberChangHost(CustId, ApartmentId, apartOid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<FamilyMemberChangeHostInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetFamilyMemberChangHost -Thay đổi thông tin chủ hộ
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetFamilyMemberChangHost([FromBody] FamilyMemberChangeHostInfo info)
        {
            try
            {
                var rs = await _apartmentService.SetFamilyMemberChangHost(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// GetApartmentFamilyMemberInfoAsync - Xem chi tiết thành viên căn hộ
        /// </summary>
        /// <param name="CustId">Mã khách hàng</param>
        /// <param name="ApartmentId">ID căn hộ (int) - backward compatible</param>
        /// <param name="apartOid">Mã định danh căn hộ (UUID) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<FamilyMemberInfo>> GetFamilyMemberInfo([FromQuery] string CustId, [FromQuery] int? ApartmentId, [FromQuery] Guid? apartOid)
        {
            try
            {
                var rs = await _apartmentService.GetFamilyMemberInfo(CustId, ApartmentId, apartOid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<FamilyMemberInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }

        /// <summary>
        /// GetFamilyMemberByPhoneInfoAsync - Search thành viên căn hộ theo sđt
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="filter"></param>
        /// <param name="ApartmentId">ID căn hộ (string) - backward compatible</param>
        /// <param name="apartOid">Oid căn hộ (Guid) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<FamilyMemberInfo>> GetFamilyMemberByPhone([FromQuery] string filter, [FromQuery] string ApartmentId, [FromQuery] Guid? apartOid = null)
        {
            try
            {
                var rs = await _apartmentService.GetFamilyMemberByPhone(filter, ApartmentId, apartOid);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<FamilyMemberInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// GetApartmentFamilyMemberInfoDraft - Draft thông tin thành viên
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<FamilyMemberInfo>> SetFamilyMemberDraft([FromBody] FamilyMemberInfo info)
        {
            try
            {
                var rs = await _apartmentService.SetFamilyMemberDraft(info);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<FamilyMemberInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }

        /// <summary>
        /// SetApartmentFamilyMemberInfoAsync - Thêm/sửa thông tin thành viên căn hộ
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetFamilyMemberInfo([FromBody] FamilyMemberInfo info)
        {
            try
            {
                var rs = await _apartmentService.SetFamilyMemberInfo(info);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// DeleteApartmentFamilyMemberAsync - Xóa thành viên thuộc căn hộ
        /// </summary>
        /// <param name="CustId">Mã khách hàng - backward compatible</param>
        /// <param name="apartmentId">ID căn hộ (int) - backward compatible</param>
        /// <param name="Oid">Mã định danh thành viên (UUID) - ưu tiên nếu có</param>
        /// <param name="apartOid">Mã định danh căn hộ (UUID) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelFamilyMember([FromQuery] string CustId, [FromQuery] int? apartmentId, [FromQuery] Guid? Oid, [FromQuery] Guid? apartOid)
        {
            try
            {
                var rs = await _apartmentService.DelFamilyMember(CustId, apartmentId, Oid, apartOid);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "");
                rp.Message = rs.messages;
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse<string>(ApiResult.Error, null, e.Message);
            }
        }

        /// <summary>
        /// LeaveMembersBulk - Rời đi (hàng loạt)
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> LeaveMembersBulk([FromBody] FamilyMemberLeaveBulkRequest request)
        {
            try
            {
                var rs = await _apartmentService.LeaveMembersBulk(UserId, request.ApartmentId, request.CustIds, request.ActionDate, request.Note);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }
        /// <summary>
        /// GetMemberHistoryPage - Lịch sử thành viên căn hộ
        /// </summary>
        /// <param name="query"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetMemberHistoryPage([FromQuery] MemberHistoryRequestModel query)
        {
            try
            {
                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _apartmentService.GetMemberHistoryPage(query);
                var rp = GetResponse(ApiResult.Success, rs);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<CommonDataPage>(ApiResult.Error, e.Message);
                return rp;
            }
        }

        /// <summary>
        /// Set Auth Family Member
        /// </summary>
        /// <param name="customer"></param>
        /// <returns></returns>
        [ServiceFilter(typeof(AuditFilterAttribute))]
        [HttpPut]
        public async Task<BaseResponse<string>> SetFamilyMemberAuth([FromBody] HomMemberBase customer)
        {
            var result = await _apartmentService.SetFamilyMemberAuth(customer);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                var response = GetResponse<string>(ApiResult.Error, null);
                response.SetStatus(2, result.messages);
                return response;
            }
        }
        #endregion

        #region Merge_Member
        /// <summary>
        /// GetMergeMemberInfo - lấy thông tin merge (ArrObj)
        /// </summary>
        /// <summary>
        /// GetMergeMemberInfo - lấy thông tin merge (dataList table) để truyền xuống DB khi SET
        /// </summary>
        [HttpPost]
        public async Task<BaseResponse<MergeMemberInfo>> GetMergeMemberInfo([FromBody] GetMergeMemberInfoRequest query)
        {
            try
            {
                if (query == null)
                {
                    query = new GetMergeMemberInfoRequest();
                }

                query.userId = UserId;
                query.clientId = ClientId;
                var rs = await _apartmentService.GetMergeMemberInfo(query);
                var rp = GetResponse(ApiResult.Success, rs);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<MergeMemberInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        /// <summary>
        /// SetMergeMemberInfo - Gộp thành viên (thành viên trên vào thành viên dưới)
        /// </summary>
        /// <summary>
        /// SetMergeMemberInfo - Gộp thành viên (sử dụng dataList)
        /// </summary>
        [HttpPost]
        public async Task<BaseResponse<string>> SetMergeMemberInfo([FromBody] MergeMemberInfo request)
        {
            try
            {
                if (request == null)
                {
                    return GetResponse<string>(ApiResult.Error, null, "Request body is required");
                }

                var rs = await _apartmentService.SetMergeMemberInfo(UserId, request);
                var rp = GetResponse(rs.valid ? ApiResult.Success : ApiResult.Error, "", rs.messages);
                return rp;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return GetResponse(ApiResult.Error, "", e.Message);
            }
        }

        /// <summary>
        /// SetMergeMemberDraft - Draft thông tin gộp thành viên
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<FamilyMemberInfo>> SetMergeMemberDraft([FromBody] FamilyMemberInfo info)
        {
            try
            {
                var rs = await _apartmentService.SetMergeMemberDraft(info);
                var sCode = rs != null ? ApiResult.Success : ApiResult.Error;
                var response = GetResponse(sCode, rs);
                return response;
            }
            catch (Exception e)
            {
                _logger.LogError($"{e}");
                var rp = new BaseResponse<FamilyMemberInfo>(ApiResult.Error, e.Message);
                return rp;
            }
        }
        #endregion

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="apartmentId">ID căn hộ (int) - backward compatible</param>
        /// <param name="custId"></param>
        /// <param name="filter"></param>
        /// <param name="apartOid">Oid căn hộ (Guid) - ưu tiên nếu có</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetApartmentMemberForDropdownList([FromQuery] int apartmentId, [FromQuery] Guid? custId, [FromQuery] string filter, [FromQuery] Guid? apartOid = null)
        {
            try
            {
                var result = await _apartmentService.GetApartmentMemberForDropdownList(apartmentId, custId, filter, apartOid);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetResponse(ApiResult.Error, new List<CommonValue>(), ex.Message);
            }
        }
    }
}
