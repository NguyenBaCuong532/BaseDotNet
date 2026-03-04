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
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.Model.Resident;

namespace SSG.SupApp.API.Controllers.Version1
{

    /// <summary>
    /// Super App
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 07/02/2020 9:31 AM
    /// <seealso cref="SSGController" />
    [Route("api/v1/notify/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class NotifyController : SSGController
    {

        private readonly IUserAppService1 _userService;
        private readonly IAppNotifyService _appService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Initializes a new instance of the <see cref="NotifyController"/> class.
        /// </summary>
        /// <param name="userService"></param>
        /// <param name="appService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        public NotifyController(
            IUserAppService1 userService,
            IAppNotifyService appService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger) : base(appSettings, logger)
        {
            _userService = userService;
            _appService = appService;
        }

        #region notification-reg
        /// <summary>
        /// GetProjectList
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public BaseResponse<List<ProjectApp>> GetProjectList()
        {
            var result = _userService.GetProjectList(this.UserId);
            return GetResponse(ApiResult.Success, result);
        }        
        /// <summary>
        /// List of Notification is received
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<SentNotifyPage>> GetNotificationPageAsync(
            [FromQuery] string projectCd,
            [FromQuery] Guid? source_ref,
            [FromQuery] int? isHighLight,
            [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            var flt = new FilterBase
            {
                clientId = this.ClientId,
                userId = this.UserId,
                offSet = offSet,
                pageSize = pageSize,
                //projectCd = projectCd,
                filter = "s-resident",
                customOid = source_ref,
                gridWidth = isHighLight
            };
            //var flt = new FilterBase1(this.ClientId, this.UserId, offSet, pageSize, projectCd, 0, "s-resident", 0, 0);
            var result = await _appService.GetNotifyByUser(flt, projectCd);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Notification Full
        /// </summary>
        /// <param name="n_id"></param>
        /// <returns>
        /// ```json
        /// {
        ///     "NotiId": 0  mã số. vơi giá trị bằng 0 là thêm mới; lớn hơn 0 là sửa,
        ///     "Subject": "Tiêu đề" ,
        ///     "Description": "Mô tả",
        ///     "contentType": 0  kiểu nội dung nhập 0: dạng text thường; 1: dạng markdown; 2: dạng html,
        ///     "ContentEdit": "Nội dung lưu",
        ///     "ContentView": "nội dung khi chuyển dang dạng hml để gửi mail" ,
        ///     "PushTimeAgo": "Thời gian công bố",
        ///     "contentType": 1 kiểu nội dung của ContentEdit với 0: dạng text thường; 1: dạng markdown; 2: dạng html,
        ///     "UserName": "Người dùng",
        ///     "IsRead": true  trạng thái đọc
        /// }
        /// ```
        /// </returns>
        [HttpGet]
        public async Task<BaseResponse<SentNotifyGet>> GetNotificationInfoAsync([FromQuery] Guid n_id)
        {
            var result = await _appService.GetSentNotifyDetail(n_id);
            return GetResponse(ApiResult.Success, result);
        }

        #endregion notification-reg

        #region feedback-reg
        /// <summary>
        /// Get FeedbackType list
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetFeedbackType()
        {
            var result = await _appService.GetFeedbackType();
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Send feed back
        /// </summary>
        /// <param name="feedback"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SendFeedback([FromBody] Feedback feedback)
        {
            await _appService.SendFeedback(feedback);
            return GetResponse<string>(ApiResult.Success, null);
        }

        #endregion feedback-reg

    }
}
