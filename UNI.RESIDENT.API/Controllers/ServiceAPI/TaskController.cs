using AutoMapper;
using IdentityServer4.AccessTokenValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using UNI.Resident.API.Attributes;
using UNI.Resident.BLL.BusinessInterfaces.Notify;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model.Invoice;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Utils;

namespace UNI.Resident.API.Controllers.ServiceAPI
{
    /// <summary>
    /// Task API - Service automation
    /// </summary>
    /// 19/10/2016 11:35 AM
    /// <seealso cref="Controller" />
    [Route("api/v1/task/[action]")]
    [Authorize(AuthenticationSchemes = IdentityServerAuthenticationDefaults.AuthenticationScheme)]
    public class TaskController : UniController
    {
        //private readonly INotificationService _notificationService;
        private readonly ITaskService _taskService;
        private readonly INotifyService _notifyService;
        //private readonly IMapper _mapper;
        //private readonly IWebHostEnvironment _env;
        protected readonly ILogger _logger;
        private readonly IFirebaseRepository _fbRepository;
        /// <summary>
        /// Initializes a new instance of the <see cref="TaskController"/> class.
        /// </summary>
        /// <param name="appService"></param>
        /// <param name="taskService"></param>
        /// <param name="appSettings"></param>
        /// <param name="logger"></param>
        /// <param name="env"></param>
        /// <param name="fbRepository"></param>
        /// <param name="mapper"></param>
        public TaskController(
            //INotificationService notificationService,
            ITaskService taskService,
            INotifyService notifyService,
            IOptions<AppSettings> appSettings,
            ILoggerFactory logger,
            IFirebaseRepository fbRepository,
            IMapper mapper) : base(appSettings, logger)
        {
            //_notificationService = notificationService;
            _taskService = taskService;
            _notifyService = notifyService;
            _fbRepository = fbRepository;
            _logger = logger.CreateLogger(GetType().Name);
        }
        #region message
        /// <summary>
        /// Get Messages BySend
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<List<MessageSend>> GetMessagesBySendAsync()
        {
            return await _taskService.GetMessagesBySend();
        }
        /// <summary>
        /// Set Message
        /// </summary>
        /// <param name="message"></param>
        /// <returns></returns>
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> SetMessage([FromBody] MessageSend message)
        {
            //await _notificationService.TakeMessage(this.CtrlClient, message);
            //return GetResponse<string>(ApiResult.Success, null);
            try
            {
                if (!ModelState.IsValid)
                {
                    return GetErrorResponse<string>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }
                var result = await _taskService.TakeMessage(message);
                return GetResponse(ApiResult.Success, "Pass");
            }
            catch (Exception ex)
            {
                await _taskService.SetMessageSent(new MessageSent { messageId = message.messageId, errorNum = 500, errorDes = 1 });
                _logger.LogError(ex.StackTrace);
                return GetResponse(ApiResult.Success, "fall");
            }
        }
        #endregion message

        #region email
        /// <summary>
        /// Get Email BySend
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<List<EmailModel>> GetEmailBySendAsync([FromQuery] string id)
        {
            return await _taskService.GetEmailBySend(id);
        }
        /// <summary>
        /// Set Email
        /// </summary>
        /// <param name="mail"></param>
        /// <returns></returns>
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<BaseValidate>> SetEmail([FromBody] EmailModel mail)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return GetErrorResponse<BaseValidate>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }
                var result = await _taskService.TakeMailSend(mail);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                await _taskService.SetEmailSent(new EmailSent { id = mail.id, errorNum = 500, errorDes = ex.Message });
                _logger.LogError(ex.StackTrace);
                return GetResponse(ApiResult.Success, new BaseValidate { valid = false, messages = ex.Message });
            }
        }

        #endregion email

        #region notify
        /// <summary>
        /// Get Notify BySend
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<List<NotifyJobTake>> GetNotifyByPushAsync([FromQuery] string id)
        {
            return await _taskService.GetNotifyByPush(id);
        }
        /// <summary>
        /// Set Notify
        /// </summary>
        /// <param name="noti"></param>
        /// <returns></returns>
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> SetNotifyPush([FromBody] NotifyJobTake noti)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return GetErrorResponse<string>(ApiResult.Invalid, (int)ErrorCode.ModelInvalid, ErrorCode.ModelInvalid.GetDescription());
                }
                await _fbRepository.SetNotifyJobPush(noti);
                await _taskService.TakeNotifySend(noti);
                return GetResponse(ApiResult.Success, "pass");
            }
            catch (Exception ex)
            {
                await _taskService.SetNotifySent(noti);
                _logger.LogError("SetNotifyPush :" + ex.ToString());
                return GetResponse(ApiResult.Success, "fall");
            }
        }

        #endregion notify

        #region invoice
        /// <summary>
        /// Get Service Bill By Jobs
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [AllowAnonymous]
        [ApiKey]
        public async Task<List<ServiceBill>> GetServiceBillByJobsAsync()
        {
            return await _taskService.GetServiceBillByJobs("");
        }

        /// <summary>
        /// Get Service Bill By Jobs
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<List<ServiceBill>> GetServiceBillByJobsKafkaAsync([FromBody]string receiveIds)
        {
            return await _taskService.GetServiceBillByJobs(receiveIds);
        }
        /// <summary>
        /// Set Service Bill
        /// </summary>
        /// <param name="bills"></param>
        /// <returns></returns>
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<string>> SetServiceBill([FromBody] ServiceBill bill)
        {
            var result = await _taskService.SetServiceBill(bill);
            return GetResponse<string>(ApiResult.Success, result);
        }
        #endregion

        #region scheduled-notify
        /// <summary>
        /// Process Scheduled Notifications - Lấy và gửi thông báo đã đến lịch qua Kafka
        /// </summary>
        /// <param name="maxRecords">Số lượng thông báo tối đa cần xử lý (mặc định: 100)</param>
        /// <returns></returns>
        [HttpPost]
        [AllowAnonymous]
        [ApiKey]
        public async Task<BaseResponse<int>> ProcessScheduledNotifications([FromQuery] int maxRecords = 100)
        {
            try
            {
                _logger.LogInformation("Bắt đầu xử lý thông báo đã đến lịch gửi. MaxRecords: {MaxRecords}", maxRecords);
                
                var result = await _notifyService.ProcessScheduledNotifications(maxRecords);
                
                if (result.Result == ApiResult.Success)
                {
                    _logger.LogInformation("Hoàn thành xử lý thông báo đã đến lịch gửi. Đã xử lý: {Count}", result.Data);
                }
                else
                {
                    _logger.LogError("Lỗi khi xử lý thông báo đã đến lịch gửi: {Error}", result.Error);
                }
                
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi xử lý thông báo đã đến lịch gửi");
                return GetErrorResponse<int>(ApiResult.Error, 500, ex.Message);
            }
        }
        #endregion scheduled-notify

        /// <summary>
        /// Get Guest Id (New GUID)
        /// </summary>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpGet]
        public BaseResponse<string> GetGuestId()
        {
            return GetResponse(ApiResult.Success, Guid.NewGuid().ToString());
        }
    }
}
