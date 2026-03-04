using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using SSG.BLL.BusinessServiceInterfaces;
using SSG.Model;
using SSG.Model.Api;
using SSG.Model.APPM;
using SSG.Model.Core;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SSG.SupApp.API.Controllers.Version1
{

    /// <summary>
    /// Super App
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 07/02/2020 9:31 AM
    /// <seealso cref="SSGController" />
    [Route("api/v1/agent/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class AgentController : SSGController
    {
        //private const string _PREFIX = "ssupapp_";

        private readonly ICoreUserService _userService;
        private readonly IAppManagerService _appService;
        private readonly ICoreAgentService _custService;
        //private readonly ISPayService _spayService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="AgentController"/> class.
        /// </summary>
        /// <param name="custService"></param>
        ///// <param name="spayService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public AgentController(
            ICoreUserService userService,
            IAppManagerService appService,
            ICoreAgentService custService,
            //ISPayService spayService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _userService = userService;
            _appService = appService;
            _custService = custService;
            //_spayService = spayService;
        }

        #region agency 
        
        ///// <summary>
        ///// Set agent Comfirm - Đồng ý ký hợp đồng online
        ///// </summary>
        ///// <param name="agent"></param>
        ///// <returns></returns>
        //[HttpPut]
        //public async Task<BaseResponse<BaseValidate>> SetAgentComfirm([FromBody] coreAgentBase agent)
        //{
        //    var result = await _custService.SetAgentComfirm(this.UserId, agent);
        //    if (result.valid)
        //    {
        //        var user = _userService.GetProfileByName(this.UserId, null);
        //        await _appService.TakeOTP(this.CtrlClient, new WalUserGrant(agent.saler_id.ToString() + "-" + this.UserName, user.phone, ""));
        //        return GetResponse<BaseValidate>(ApiResult.Success, result);
        //    }
        //    else
        //    {
        //        var response = GetResponse<BaseValidate>(ApiResult.Error, null);
        //        response.SetStatus(2, result.messages);
        //        return response;
        //    }
        //}
        ///// <summary>
        ///// Set order verify - Xác nhận ký hợp đồng online
        ///// </summary>
        ///// <param name="order"></param>
        ///// <returns></returns>
        //[HttpPut]
        //public async Task<BaseResponse<BaseValidate>> SetAgentVerify([FromBody] coreAgentVerify order)
        //{
        //    userVerification code = new userVerification { loginName = order.saler_id.ToString() + "-" + this.UserName, verificationCode = order.code };
        //    var verify = _appService.SetVerificationCode(code);
        //    if (verify.Status == 1)
        //    {
        //        var result = await _custService.SetAgentVerify(UserId, order);
        //        if (result.valid)
        //        {
        //            return GetResponse<BaseValidate>(ApiResult.Success, result);
        //        }
        //        else
        //        {
        //            var response = GetResponse<BaseValidate>(ApiResult.Error, null);
        //            response.SetStatus(2, result.messages);
        //            return response;
        //        }
        //    }
        //    else
        //    {
        //        var response = GetResponse<BaseValidate>(ApiResult.Error, null);
        //        response.SetStatus(verify.Status, verify.StatusMessage);
        //        return response;
        //    }
        //}
        /// <summary>
        /// Get Agent Regs - Danh sách đăng ký của Nhân viên Saler
        /// </summary>
        /// <param name="agent_userId"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<coreAgentService>> GetAgentRegs([FromQuery] string agent_userId)
        {
            if (agent_userId == null)
                agent_userId = this.UserId;
            var result = _custService.GetAgentRegs(this.UserId, agent_userId);
            return GetResponse<List<coreAgentService>>(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Agent Reg - Chi tiêt 1 đăng ký của nhân viên Saler
        /// </summary>
        /// <param name="saler_id"></param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<coreAgentServiceGet> GetAgentReg([FromQuery] long saler_id)
        {
            var result = _custService.GetAgentReg(this.UserId, saler_id);
            return GetResponse<coreAgentServiceGet>(ApiResult.Success, result);
        }
        /// <summary>
        /// Phê duyệt trở thành nhân viên đại lý
        /// </summary>
        /// <param name="agent"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetAgentApprove([FromBody] coreAgentApprove agent)
        {
            var result = await _custService.SetAgentApprove(this.CtrlClient, agent, false);
            if (result.valid)
                return GetResponse<string>(ApiResult.Success, null);
            else
            {
                var response = GetResponse<string>(ApiResult.Error, null);
                response.SetStatus(2, result.messages);
                return response;
            }
        }
        /// <summary>
        /// Close Saler
        /// </summary>
        /// <param name="saler_id"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> SetAgentClose([FromQuery] long saler_id)
        {
            var saler = new Model.Core.coreAgentApprove { saler_Id = saler_id, approve_st = false };
            var result = await _custService.SetAgentApprove(this.CtrlClient, saler, false);
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
        /// <summary>
        /// Get Agency List
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="sub_prod_cd"></param>
        /// <param name="saler_type"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public ResponseList<List<coreAgency>> GetAgencyList([FromQuery] string filter, 
            [FromQuery] string sub_prod_cd, [FromQuery] int saler_type,
            [FromQuery] int offSet, [FromQuery] int pageSize)
        {
            var flt = new FilterBase1(this.ClientId, this.UserId, offSet, pageSize, filter,0, sub_prod_cd, 0, saler_type);
            var result = _custService.GetAgencyList(flt);
            result.SetStatus(ApiResult.Success);
            return result;
        }
        /// <summary>
        /// Get Project Of Agency
        /// </summary>
        /// <param name="sub_prod_cd"></param>
        /// <param name="agency_id">mã đại lý</param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<coreAgentProject>> GetProjectOfAgency([FromQuery] string sub_prod_cd, [FromQuery] long agency_id)
        {
            var result = _custService.GetProjectOfAgency(this.UserId, sub_prod_cd, agency_id, 0);
            return GetResponse<List<coreAgentProject>>(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Project Of Saler
        /// </summary>
        /// <param name="sub_prod_cd"></param>
        /// <param name="saler_id">saler_id = 0, thì lấy chính của user đó </param>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<coreAgentProject>> GetProjectOfAgent([FromQuery] string sub_prod_cd, [FromQuery] long saler_id)
        {
            var result = _custService.GetProjectOfAgency(this.UserId, sub_prod_cd, saler_id, 1);
            return GetResponse<List<coreAgentProject>>(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Agent Project Register
        /// </summary>
        /// <param name="project"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetAgentProjectReg([FromBody] coreAgentProjectReg project)
        {
            if (project.agent_userId == null)
                project.agent_userId = this.UserId;
            await _custService.SetAgentProjectReg(this.UserId, project);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Set Agent Project Approve
        /// </summary>
        /// <param name="project"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetAgentProjectApprove([FromBody] coreAgentProjectApprove project)
        {
            var result = await _custService.SetAgentProjectApprove(this.UserId, project);
            if (result.valid)
                return GetResponse<string>(ApiResult.Success, null);
            else
            {
                var response = GetResponse<string>(ApiResult.Error, null);
                response.SetStatus(2, result.messages);
                return response;
            }
        }
        /// <summary>
        /// Delete Agent Project
        /// </summary>
        /// <param name="project_agent_id"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelAgentProject([FromQuery] int project_agent_id)
        {
            await _custService.DelAgentProject(this.UserId, project_agent_id);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Get Agent Of Agency
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="sub_prod_cd"></param>
        /// <param name="project_cd"></param>
        /// <param name="agency_id">nếu agency_id = thì lấy agent của chính user là admin </param>
        /// <param name="approve_st"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public ResponseList<List<coreAgentServiceGet>> GetAgentOfAgency([FromQuery] string filter,
            [FromQuery] string sub_prod_cd, [FromQuery] string project_cd,
            [FromQuery] int agency_id, [FromQuery] int approve_st,
            [FromQuery] int offSet, [FromQuery] int pageSize)
        {
            var flt = new FilterBase6(this.ClientId, this.UserId, offSet, pageSize, filter, 0, agency_id, project_cd, sub_prod_cd, approve_st);
            var result = _custService.GetAgentOfAgency(flt);
            result.SetStatus(ApiResult.Success);
            return result;
        }
        /// <summary>
        /// Get Project Request Of Agency
        /// </summary>
        /// <param name="sub_prod_cd"></param>
        /// <param name="agency_id">nếu agency_id = thì lấy agent của chính user là admin</param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public ResponseList<List<coreAgentProjectRequest>> GetProjectRequestOfAgency(
            [FromQuery] string sub_prod_cd, [FromQuery] long agency_id,
            [FromQuery] int offSet, [FromQuery] int pageSize)
        {
            var flt = new FilterBase(this.ClientId, this.UserId, offSet, pageSize, "");
            var result = _custService.GetProjectRequestOfAgency(flt, sub_prod_cd, agency_id);
            result.SetStatus(ApiResult.Success);
            return result;
        }
        /// <summary>
        /// Get Support Of Agent - Danh sách các khách hàng bảo hộ của Saler
        /// </summary>
        /// <param name="sub_prod_cd"></param>
        /// <param name="saler_id"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public ResponseList<List<userProtectGet>> GetSupportOfAgent([FromQuery] string sub_prod_cd, [FromQuery] long saler_id,
            [FromQuery] int offSet, [FromQuery] int pageSize)
        {
            var flt = new FilterBase(this.ClientId, this.UserId, offSet, pageSize, "");
            var result = _custService.GetProtectOfAgent(flt, sub_prod_cd, saler_id);
            result.SetStatus(ApiResult.Success);
            return result;
        }
        ///// <summary>
        ///// Get Consultants For Chat
        ///// </summary>
        ///// <param name="sub_prod_cd"></param>
        ///// <param name="role_id"></param>
        ///// <param name="project_cd"></param>
        ///// <param name="cust_userid"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<List<coreUserChat>> GetConsultantForChat([FromQuery] string sub_prod_cd, [FromQuery] string role_id, 
        //    [FromQuery] string project_cd,
        //    [FromQuery] string cust_userid)
        //{
        //    var result = _custService.GetConsultantForChat(this.UserId, sub_prod_cd, role_id, project_cd, cust_userid);
        //    return GetResponse<List<coreUserChat>>(ApiResult.Success, result);
        //}
        ///// <summary>
        ///// Get Agent For Chat
        ///// </summary>
        ///// <param name="sub_prod_cd"></param>
        ///// <param name="role_id"></param>
        ///// <param name="project_cd"></param>
        ///// <param name="cust_userid"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<List<coreUserChat>> GetAgentForChat([FromQuery] string sub_prod_cd, [FromQuery] string role_id, 
        //    [FromQuery] string project_cd,
        //    [FromQuery] string cust_userid)
        //{
        //    var result = _custService.GetAgentForChat(this.UserId, sub_prod_cd, role_id, project_cd, cust_userid);
        //    return GetResponse<List<coreUserChat>>(ApiResult.Success, result);
        //}
        ///// <summary>
        ///// Get Manager For Chat
        ///// </summary>
        ///// <param name="sub_prod_cd"></param>
        ///// <param name="role_id"></param>
        ///// <param name="project_cd"></param>
        ///// <param name="cust_userid"></param>
        ///// <returns></returns>
        //[HttpGet]
        //public BaseResponse<List<coreUserChat>> GetManagerForChat([FromQuery] string sub_prod_cd, [FromQuery] string role_id, 
        //    [FromQuery] string project_cd,
        //    [FromQuery] string cust_userid)
        //{
        //    var result = _custService.GetManagerForChat(this.UserId, sub_prod_cd, role_id, project_cd, cust_userid);
        //    return GetResponse<List<coreUserChat>>(ApiResult.Success, result);
        //}
        #endregion agency
    }
}
