using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Resident.BLL.BusinessInterfaces.Notify;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Notification;
using UNI.Resident.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.APPM.Notifications;
using UNI.Utils;
using UNI.Resident.BLL.BusinessInterfaces.Settings;

namespace UNI.Resident.API.Controllers.Version2.Visitor
{

    /// <summary>
    /// Notify
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 12/032017 2:11 PM
    /// <seealso cref="ControllerBase" />
    [Route("api/v2/notify/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class NotifyController : UniController
    {
        /// <summary>
        /// Notify Service
        /// </summary>
        /// Author: duongpx
        /// CreatedDate: 12/032017 2:11 PM
        //private readonly IUserService _hrmService;
        //private readonly IApiSenderService _emailSender;
        private readonly INotifyService _notiService;
        //private readonly IApartmentService _apartmentService;
        private readonly NotifySetting _notifySettings;
        private readonly ICommonService _commService;
        private const string sendMail = "notify_email_filter";
        private const string sendMessages = "notify_sms_filter";

        /// <summary>
        /// Initializes a new instance of the <see cref="NotifyController"/> class.
        /// </summary>
        /// <param name="prodService"></param>
        /// <param name="appService"></param>
        /// <param name="apartmentService"></param>
        /// <param name="commService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="storageService"></param>
        /// <param name="emailSender"></param>
        public NotifyController(
            IUserService prodService,
                IApiSenderService emailSender,
            INotifyService appService,
            //IApartmentService apartmentService,
            ICommonService commService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IApiStorageService storageService
            ) : base(appSettings, logger, storageService)
        {
            //_hrmService = prodService;
            //_emailSender = emailSender;
            //_apartmentService = apartmentService;
            _notiService = appService;
            _commService = commService;
            _notifySettings = appSettings.Value.Notify;
        }


        #region Notify-manager
        /// <summary>
        /// GetNotifyFilter
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetNotifyFilterAsync()
        {
            var result = await _notiService.GetNotifyFilter("notify_filter1");
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetNotiPushStatus
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetNotifyPushStatusAsync()
        {
            var result = await _notiService.GetNotiPushStatus(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetNotifyActions
        /// </summary>
        /// <param name="all"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetNotifyActions([FromQuery] string all)
        {
            var result = await _commService.GetObjectList("actionlist", all);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// SetDocumentUrl
        /// </summary>
        /// <param name="doc"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetDocumentUrl([FromBody] HomDocumentUrlSet doc)
        {
            await _notiService.SetDocumentUrl(doc);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// GetDocumentUrl
        /// </summary>
        /// <param name="projectCd"></param>
        /// <param name="filter"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetDocumentUrl([FromQuery] string projectCd, [FromQuery] string filter,
            [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            var flt = new FilterInputProject { clientId = ClientId, userId = UserId, offSet = offSet, pageSize = pageSize, filter = filter, projectCd = projectCd };
            var result = await _notiService.GetDocumentUrl(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get App Notification Page - Trang thông báo cho quản trị
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetNotifyPageAsync(
            [FromQuery] FilterInpNotify flt
            )
        {
            flt.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _notiService.GetAppNotifyPage(flt, _notifySettings.ExternalKey);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// GetNotifyInfo
        /// </summary>
        /// <param name="n_id"></param>
        /// <param name="tempId"></param>
        ///// <param name="external_sub"></param>
        ///// <param name="external_name"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<resNotifyInfo>> GetNotifyInfo(
            [FromQuery] Guid? n_id,
            [FromQuery] Guid? tempId,
            [FromQuery] string actions,
            [FromQuery] int? to_level,
            [FromQuery] string external_sub,
            [FromQuery] string to_groups
            )
        {
            var para = new NotifyParam
            {
                n_id = n_id,
                tempId = tempId,//
                external_sub = external_sub, 
                actions = actions,
                to_level = to_level,
                to_groups = to_groups,
                to_type = 1
            };
            var result = await _notiService.GetNotifyInfo(para, _notifySettings.ExternalKey);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// SetNotifyDraft
        /// </summary>
        /// <param name="noti"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<resNotifyInfo>> SetNotifyDraft([FromBody] resNotifyInfoSet noti)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<resNotifyInfo>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _notiService.SetNotifyDraft(noti);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Notification
        /// </summary>
        /// <param name="noti">        
        /// </param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetNotifyInfo([FromBody] resNotifyInfoSet noti)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _notiService.SetNotifyInfo(noti);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result);
            }
            else
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// GetNotifyToPage
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetNotifyToPageAsync(
            [FromQuery] FilterInpNotifyId flt
            )
        {
            flt.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _notiService.GetNotifyToPage(flt);
            return GetResponse(ApiResult.Success, result);
        }
        
        /// <summary>
        /// SetNotifyStatus Thay đổi trang thái
        /// </summary>
        /// <param name="noti">status: có 2 giá trị: 0, 1 </param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<string>> SetNotifyStatus([FromBody] AppNotifyId noti)
        {
            var result = await _notiService.SetAppNotifyStatus(noti);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result.messages);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// DelNotifyInfo
        /// </summary>
        /// <param name="n_id"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelNotifyInfo([FromQuery] Guid n_id)
        {
            var result = await _notiService.DelNotifyInfo(n_id);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }

        #endregion Notify-manager

        #region notify to

        /// <summary>
        /// GetNotifyToList - Lấy danh sách chia sẻ
        /// </summary>
        /// <param name="n_id"></param>
        /// <param name="to_level"></param>
        /// <param name="to_groups"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<NotifyToListGet>> GetNotifyToList([FromQuery] Guid? n_id, [FromQuery] int? to_level, [FromQuery] string to_groups)
        {
            var result = await _notiService.GetNotifyToList(n_id, to_level, to_groups, 1);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// SetNotifyToList - Lưu danh sách chia sẻ
        /// </summary>
        /// <param name="notiTo"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetNotifyToList([FromBody] NotifyToList notiTo)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _notiService.SetNotifyToList(notiTo);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result);
            }
            else
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// GetNotifyTo
        /// </summary>
        /// <param name="n_id"></param>
        /// <param name="to_groups"></param>
        /// <param name="to_level"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<NotifyTo>> GetNotifyTo([FromQuery] Guid? n_id, [FromQuery] Guid? id, [FromQuery] int? to_level, [FromQuery] string to_groups)
        {
            var result = await _notiService.GetNotifyTo(n_id, id, to_level, to_groups, 1);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetNotifyToDraft
        /// </summary>
        /// <param name="notiTo"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<NotifyTo>> SetNotifyToDraft([FromBody] NotifyTo notiTo)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<NotifyTo>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _notiService.SetNotifyToDraft(notiTo);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetNotifyToDraft
        /// </summary>
        /// <param name="notiTo"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<CommonDataPage>> SetNotifyToDraftPage([FromBody] NotifyTo notiTo)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<CommonDataPage>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _notiService.SetNotifyToDraftPage(notiTo);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// SetNotifyTo
        /// </summary>
        /// <param name="notiTo"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetNotifyTo([FromBody] NotifyTo notiTo)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _notiService.SetNotifyTo(notiTo);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result);
            }
            else
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// DelNotifyTo
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelNotifyTo([FromQuery] Guid id)
        {
            var result = await _notiService.DelNotifyTo(id);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }

        #endregion notify to

        #region notify-push
        /// <summary>
        /// GetLeaveFilter
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetNotifyToPushsFilter([FromQuery] Guid? n_id)
        {
            var result = await _notiService.GetNotifyToPushsFilter(n_id);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// SetNotifyCreatePush
        /// </summary>
        /// <param name="noti"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetNotifyCreatePush([FromBody] PushNotifyHomSet noti)
        {
            var userlist = await _notiService.GetFamilyPush(noti);
            var pushs = new PushNotifyCreate { n_id = noti.n_id, appUsers = userlist };
            var result = await _notiService.SetNotifyCreatePush(pushs);
            if (result.valid)
                return GetResponse(ApiResult.Success, result.messages);
            else
                return GetResponse<string>(ApiResult.Error, null, result.messages);
        }
        /// <summary>
        /// Get Noti To Pushs
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetNotifyToPushs(
            [FromQuery] FilterInpNotifyPush flt
            )
        {
            flt.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _notiService.GetNotiToPushPage(flt);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Set NotiTo Pushs - Tạo gửi
        /// </summary>
        /// <param name="noti">with action = push|sms|email</param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetNotifyToPushRun([FromBody] PushNotifyRun noti)
        {
            await _notiService.SetNotifyToPushRun(noti);
            return GetResponse<string>(ApiResult.Success, null);
        }
        /// <summary>
        /// Delete Notification by Manager
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpDelete]
        public async Task<BaseResponse<string>> DelNotifyPush([FromQuery] string id)
        {
            var result = await _notiService.DelNotiPush(id);
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
        /// Del Noti Pushs
        /// </summary>
        /// <param name="ids"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> DelNotifyPushs([FromBody] PushNotifyDel ids)
        {
            var result = await _notiService.DelNotiPushs(ids);
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

        #endregion notify-push

        #region notify-comment
        /// <summary>
        /// Set Notification Comment
        /// </summary>
        /// <param name="comm"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<AppNotifyComment>> SetNotifyCommentAsync([FromBody] AppNotifyCommentSet comm)
        {
            var result = await _notiService.SetNotiComment(comm);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Noti Comment List
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetNotifyCommentList(
            [FromQuery] FilterInpNotifyId flt
            )
        {
            flt.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _notiService.GetNotiComments(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Get Noti Comment Childs
        /// </summary>
        /// <param name="commentId"></param>
        /// <param name="offSet"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetNotifyCommentChilds([FromQuery] int commentId,
            [FromQuery] int? offSet, [FromQuery] int? pageSize)
        {
            var flt = new FilterBase(ClientId, UserId, offSet, pageSize, "", commentId);
            var result = await _notiService.GetNotiCommentById(flt);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// Set Notification Comment by Manager
        /// </summary>
        /// <param name="comm"></param>
        /// <returns></returns>
        [HttpPut]
        public async Task<BaseResponse<string>> SetNotifyCommentAuth([FromBody] AppNotifyCommentAuth comm)
        {
            var result = await _notiService.SetNotiCommentAuth(comm);
            return GetResponse<string>(ApiResult.Success, null);
        }

        #endregion notify-comment

        #region Notify-emp
        /// <summary>
        /// List of Notification with Send
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetNotifySentPage(
            [FromQuery] FilterInpNotifyUser flt
            )
        {
            flt.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _notiService.GetNotifySentPageByUser(flt);
            return GetResponse(ApiResult.Success, result);
        }

        #endregion Notify-emp

        #region Notify-ref

        /// <summary>
        /// GetNotifyRefList - DS phân loại thông báo
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetNotifyRefListAsync()
        {
            var result = await _notiService.GetNotifyRefList(_notifySettings.ExternalKey);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetNotifyRefPage - Trang phân loại thông báo
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetNotifyRefPageAsync(
            [FromQuery] FilterInput flt
            )
        {
            flt.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _notiService.GetNotifyRefPage(flt, _notifySettings.ExternalKey);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetNotifyRef - Xem chi tiết
        /// </summary>
        /// <param name="source_ref"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<AppNotifyRef>> GetNotifyRefAsync([FromQuery] Guid? source_ref)
        {
            var result = await _notiService.GetNotifyRef(source_ref, _notifySettings.ExternalKey);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// SetNotifyRef - Lưu thông tin
        /// </summary>
        /// <param name="noti">        
        /// </param>
        /// <returns></returns>
        [HttpPost]
        //[Authorize(Policy = SSGPolicy.SHOME_MAN)]
        public async Task<BaseResponse<BaseValidate>> SetNotifyRef([FromBody] AppNotifyRef noti)
        {
            var result = await _notiService.SetNotifyRef(noti);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result);
            }
            else
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// DelNotifyRef - Xóa loại thông báo
        /// </summary>
        /// <param name="source_ref"></param>
        /// <returns></returns>
        [HttpDelete]
        //[Authorize(Policy = SSGPolicy.SHOME_MAN)]
        public async Task<BaseResponse<string>> DelNotifyRef([FromQuery] Guid source_ref)
        {
            var result = await _notiService.DelNotifyRef(source_ref);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result.messages);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }

        #endregion Notify-ref

        #region Notify-temp
        /// <summary>
        /// GetNotifyTempFilter
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetNotifyTempFilterAsync()
        {
            var result = await _notiService.GetNotifyTempFilter(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetNotifyTempList - DS mẫu thông báo
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetNotifyTempListAsync([FromHeader] string projectcode)
        {
            var result = await _notiService.GetNotifyTempList(_notifySettings.ExternalKey, null, projectcode);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetNotifyTempPage - Trang mẫu thông báo 
        /// </summary>
        /// <param name="flt"></param>
        /// <param name="projectcode"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetNotifyTempPageAsync([FromQuery] FilterInpNotifyTemp flt, [FromHeader] string projectcode)
        {
            flt.ucInput(UserId, ClientId, AcceptLanguage);
            var result = await _notiService.GetNotifyTempPage(flt, _notifySettings.ExternalKey, projectcode);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// GetNotifyTemp - CHi tiết mẫu thông báo
        /// </summary>
        /// <param name="tempId"></param>
        /// <param name="source_key"></param>
        /// <param name="n_id"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<NotifyTemp>> GetNotifyTempAsync(
            [FromQuery] Guid? tempId,
            [FromQuery] Guid? n_id)
        {
            var result = await _notiService.GetNotifyTemp(tempId, n_id, _notifySettings.ExternalKey);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// SetNotifyTempDraft
        /// </summary>
        /// <param name="noti"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<NotifyTemp>> SetNotifyTempDraft([FromBody] NotifyTemp noti)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<NotifyTemp>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _notiService.SetNotifyTempDraft(noti);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// SetNotifyTemp - Lưu mẫu thông báo
        /// </summary>
        /// <param name="noti">        
        /// </param>
        /// <returns></returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetNotifyTemp([FromBody] NotifyTemp noti)
        {
            if (!ModelState.IsValid)
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
            }
            var result = await _notiService.SetNotifyTemp(noti);
            if (result.valid)
            {
                return GetResponse(ApiResult.Success, result);
            }
            else
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// DelNotifyTemp - Xóa mẫu thông báo
        /// </summary>
        /// <param name="tempId"></param>
        /// <returns></returns>
        [HttpDelete]
        //[Authorize(Policy = SSGPolicy.SHOME_MAN)]
        public async Task<BaseResponse<string>> DelNotifyTemp([FromQuery, Required] Guid tempId)
        {
            var result = await _notiService.DelNotifyTemp(tempId);
            if (result.valid)
            {
                return GetResponse<string>(ApiResult.Success, null);
            }
            else
            {
                return GetErrorResponse<string>(ApiResult.Error, 2, result.messages);
            }
        }
        /// <summary>
        /// GetNotifyFields
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetNotifyFieldsAsync()
        {
            var result = await _notiService.GetNotifyFields(UserId);
            return GetResponse(ApiResult.Success, result);
        }
        /// <summary>
        /// GetNotifyTemplateFields - Lấy danh sách field của một template cụ thể
        /// </summary>
        /// <param name="tempId">ID của template</param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<List<CommonValue>>> GetNotifyTemplateFieldsAsync([FromQuery, Required] Guid tempId)
        {
            var result = await _notiService.GetNotifyTemplateFields(tempId);
            return GetResponse(ApiResult.Success, result);
        }
        #endregion Notify-temp

        #region notify-page
        /// <summary>
        /// Get send mail filter
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetNotifyMailFilterAsync()
        {
            var result = await _notiService.GetNotifyFilter(sendMail);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Lịch sử gửi mail
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetNotifyMailPageAsync(
            [FromQuery] FilterInpNotifySend flt
            )
        {
            flt.ucInputDt(UserId, ClientId, AcceptLanguage);
            var result = await _notiService.GetNotifyEmailPage(flt, _notifySettings.ExternalKey);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Get send messages filter
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetNotifyMessageFilterAsync()
        {
            var result = await _notiService.GetNotifyFilter(sendMessages);
            return GetResponse(ApiResult.Success, result);
        }

        /// <summary>
        /// Lịch sử gửi messages
        /// </summary>
        /// <param name="flt"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<BaseResponse<CommonDataPage>> GetNotifyMessagePageAsync(
            [FromQuery] FilterInpNotifySend flt
            )
        {
            flt.ucInputDt(UserId, ClientId, AcceptLanguage);
            var result = await _notiService.GetNotifyMessagePage(flt, _notifySettings.ExternalKey);
            return GetResponse(ApiResult.Success, result);
        }
        #endregion

        #region notify-sent-import-reg
        /// <summary>
        /// SetNotifySentImport - Upload và validate file Excel danh sách gửi thông báo
        /// </summary>
        /// <param name="input">Input chứa file và n_id</param>
        /// <returns></returns>
        [HttpPost]
        //[Authorize(Roles = UNIPolicy.SHOME_MAN)]
        public async Task<BaseResponse<ImportListPage>> SetNotifySentImport([FromForm] NotifySentImportInput input)
        {
            if (input?.n_id == null || input.n_id == Guid.Empty)
            {
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "n_id không được để trống");
            }

            // DoImportFile<TImport, TImportSet>(
            //   file,              // File Excel từ client
            //   fromRow: 5,        // Bắt đầu đọc từ dòng 5 (skip 4 dòng header)
            //   serviceHandler     // Delegate gọi NotifyService.SetNotifySentImport
            // )
            return await DoImportFile<NotifySentImport, NotifySentImportSet>(input.file, 5,
                records => _notiService.SetNotifySentImport(records, input.n_id));
        }

        /// <summary>
        /// SetNotifySentImportAccept - Accept và lưu dữ liệu đã validate
        /// </summary>
        /// <param name="importSet">Dữ liệu import đã validate</param>
        /// <returns></returns>
        [HttpPost]
        //[Authorize(Roles = UNIPolicy.SHOME_MAN)]
        public async Task<BaseResponse<ImportListPage>> SetNotifySentImportAccept([FromBody] NotifySentImportSet importSet)
        {
            try
            {
                if (importSet.n_id == null || importSet.n_id == Guid.Empty)
                {
                    return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, "n_id không được để trống");
                }

                // Gọi service với accept=false để lưu dữ liệu thật
                var rs = await _notiService.SetNotifySentImport(importSet, importSet.n_id.Value);
                return GetResponse(ApiResult.Success, rs);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                return GetErrorResponse<ImportListPage>(ApiResult.Error, 2, e.Message);
            }
        }

        /// <summary>
        /// SetNotifySentImportTemp - Download template Excel để import danh sách gửi thông báo
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        //[Authorize(Roles = UNIPolicy.SHOME_MAN)]
        public async Task<FileStreamResult> SetNotifySentImportTemp()
        {
            try
            {
                var rs = await _notiService.GetNotifySentImportTemp();
                return File(rs.Data, "application/octet-stream", "temp_danh_sach_gui_thong_bao.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                return null;
            }
        }
        #endregion notify-sent-import-reg
                
    }
}