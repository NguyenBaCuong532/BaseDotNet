using Microsoft.Extensions.Logging;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Model.Email;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Notification;
using UNI.Resident.Model.Resident;
using UNI.Utils;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Resident.BLL.BusinessInterfaces.Notify;
using UNI.Resident.DAL.Interfaces.Notify;

namespace UNI.Resident.BLL.BusinessService.Notify
{
    public class NotificationService : INotificationService
    {
        private readonly INotificationRepository _notifyRepository;
        private readonly IApiSenderService _sender;
        private readonly ILogger<NotificationService> _logger;
        public NotificationService(
            INotificationRepository notificationRepository,
            ILogger<NotificationService> logger,
            IApiSenderService sender)
        {
            if (notificationRepository != null)
                _notifyRepository = notificationRepository;
                _logger = logger;
                _sender = sender;
        }

        public CommonListPage GetAppNotifyPage(FilterInpNotify filter)
        {
            return _notifyRepository.GetAppNotifyPage(filter);
        }
        public Task<NotificationInfo> GetNotificationInfo(string userId, Guid? notiId, string external_key, string external_sub, string brand_name, string send_name, string external_event = null)
        {
            return _notifyRepository.GetNotificationInfo(userId, notiId, external_key, external_sub, brand_name, send_name, external_event);
        }
        public Task<NotificationInfo> SetAppNotifyDraft(string userId, NotificationInfo noti)
        {
            return _notifyRepository.SetAppNotifyDraft(userId, noti);
        }
        public Task<BaseValidate> SetAppNotifyInfo(BaseCtrlClient clt, NotificationInfo noti)
        {
            return _notifyRepository.SetAppNotifyInfo(clt, noti);
        }
        public Task<BaseValidate> DelAppNotifyInfo(string userId, Guid notiId)
        {
            return _notifyRepository.DelAppNotifyInfo(userId, notiId);
        }

        public CommonListPage GetAppNotiToPushPage(FilterInpNotifyPush filter)
        {
            return _notifyRepository.GetAppNotifyPushPageByNotiId(filter);
        }

        public Task<BaseValidate> DelNotiPush(string userId, string id)
        {
            return _notifyRepository.DelNotiPush(userId, id);
        }
        public async Task<BaseValidate> DelNotiPushs(string userId, PushNotifyDel ids)
        {
            var valid = new BaseValidate { valid = true };
            foreach (var id in ids.ids)
            {
                var result = await _notifyRepository.DelNotiPush(userId, id);
                if (result.valid == false)
                {
                    valid.valid = false;
                    valid.messages = "Có một số dữ liệu đã được gửi đến khác hàng không thể xóa!";
                }
            }
            return valid;
        }

        public Task<BaseValidate> SetNotifyCreatePush(string userId, PushNotifyCreate noti)
        {
            return _notifyRepository.SetNotifyCreatePush(userId, noti);
        }
        public async Task SetNotifyToPushRun(string userId, PushNotifyRun noti)
        {
            await _notifyRepository.SetNotifyToPushRun(userId, noti);
        }
        public CommonListPage GetMessagePage(FilterInpNotifySend filter)
        {
            return _notifyRepository.GetMessageSents(filter);
        }
        
        public async Task<MessageRespone> TakeMessage(BaseCtrlClient clt, MessageSend mess)
        {
            if (mess.partner == null)
                mess.partner = "iris";
            var response = await _sender.SendSmsAs(mess);
            mess.isSent = true;
            await _notifyRepository.TakeMessage(clt, mess);
            return response;

        }
        public CommonListPage GetEmailPage(FilterInpNotifySend filter)
        {
            return _notifyRepository.GetEmailSents(filter);
        }
        public async Task<BaseValidate> TakeMailSend(BaseCtrlClient clt, EmailModel email)
        {
            try
            {
                //if (string.IsNullOrEmpty(email.SendingTime))
                // {
                if (string.IsNullOrEmpty(email.id)) { email.id = Guid.NewGuid().ToString(); }
                bool bAttach = email.attachUrls != null && email.attachUrls.Count > 0;
                var directoryPath = Path.Combine(Path.GetTempPath(), email.id);
                if (bAttach)
                {
                    if (!Directory.Exists(directoryPath))
                    {
                        Directory.CreateDirectory(directoryPath);
                    }
                    await DownloadAttachment(directoryPath, email.attachUrls);
                    email.Attachs = ListFiles(directoryPath);
                }
                else
                {
                    bAttach = email.Attachs != null && email.Attachs.Count > 0;
                    if (bAttach)
                    {
                        if (!Directory.Exists(directoryPath))
                        {
                            Directory.CreateDirectory(directoryPath);
                        }
                        await DownloadAttachment(directoryPath, email.Attachs);
                        email.Attachs = ListFiles(directoryPath);
                    }
                }
                await (Task<EmailResponse>)_sender.SendMailgunEmail(email);
                if (bAttach) CleanFolder(directoryPath);
                // }
                email.isSent = true;
                await _notifyRepository.TakeSendMail(clt, email);
                return new BaseValidate { valid = true };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.StackTrace);
                return new BaseValidate { valid = false, messages = ex.Message };
            }
        }
        private async Task DownloadAttachment(string parentPath, List<EmailAttach> attachs)
        {
            if (attachs != null)
            {
                foreach (var url in attachs)
                {
                    Uri remoteImgPathUri = new Uri(url.attach_url);
                    string remoteImgPathWithoutQuery = remoteImgPathUri.AbsolutePath;
                    string fileName = utf8Convert3(url.attach_name) + (string.IsNullOrEmpty(url.attach_type) ? ".pdf" : url.attach_type); // Path.GetFileName(remoteImgPathWithoutQuery);
                    fileName = string.Join("_", fileName.Split(Path.GetInvalidFileNameChars()));
                    var filepath = $"{parentPath}\\{fileName}";

                    var client = new HttpClient();
                    var request = new HttpRequestMessage(HttpMethod.Get, url.attach_url);
                    var response = await client.SendAsync(request);
                    var contentStream = await response.Content.ReadAsStreamAsync();
                    FileStream fileStream = new FileStream(filepath, FileMode.Create, FileAccess.Write, FileShare.None, 3145728, true);
                    await contentStream.CopyToAsync(fileStream);

                    fileStream.Dispose();
                    contentStream.Dispose();
                    response.Dispose();
                    request.Dispose();
                    client.Dispose();
                }
            }
        }
        private async Task DownloadAttachment(string parentPath, List<string> attachs)
        {
            if (attachs != null)
            {
                foreach (var url in attachs)
                {
                    Uri remoteImgPathUri = new Uri(url);
                    string remoteImgPathWithoutQuery = remoteImgPathUri.LocalPath;
                    string fileName = DateTime.Now.ToString("yyMMddHHmmsss") + utf8Convert3(Path.GetFileName(remoteImgPathWithoutQuery));
                    fileName = string.Join("_", fileName.Split(Path.GetInvalidFileNameChars()));
                    var filepath = $"{parentPath}\\{fileName}";

                    var client = new HttpClient();
                    var request = new HttpRequestMessage(HttpMethod.Get, url);
                    var response = await client.SendAsync(request);
                    var contentStream = await response.Content.ReadAsStreamAsync();
                    FileStream fileStream = new FileStream(filepath, FileMode.Create, FileAccess.Write, FileShare.None, 3145728, true);
                    await contentStream.CopyToAsync(fileStream);

                    fileStream.Dispose();
                    contentStream.Dispose();
                    response.Dispose();
                    request.Dispose();
                    client.Dispose();
                }
            }
        }
        private string utf8Convert3(string s)
        {
            if (s == null)
                return "";
            Regex regex = new Regex("\\p{IsCombiningDiacriticalMarks}+");
            string temp = s.Normalize(NormalizationForm.FormD);
            return regex.Replace(temp, string.Empty).Replace('\u0111', 'd').Replace('\u0110', 'D');
        }
        private List<string> ListFiles(string folderPath)
        {
            List<string> result = new List<string>();
            DirectoryInfo di = new DirectoryInfo(folderPath);
            foreach (FileInfo file in di.GetFiles())
            {
                result.Add(file.FullName);
            }
            return result;
        }
        private void CleanFolder(string folderPath)
        {
            try
            {
                DirectoryInfo di = new DirectoryInfo(folderPath);

                foreach (FileInfo file in di.GetFiles())
                {
                    file.Delete();
                }
                foreach (DirectoryInfo dir in di.GetDirectories())
                {
                    dir.Delete(true);
                }
                di.Delete();
            }
            catch { }
        }

        public async Task<BaseValidate<Stream>> GetRoomNotifySendTemp(string userId, string projectCd, string buildingCd)
        {
            try
            {
                var ds = await _notifyRepository.GetRoomNotifySendTemp(userId, projectCd, buildingCd);
                var r = new FlexcellUtils();
                var template = await File.ReadAllBytesAsync($"templates/notify/import_room_notification.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, ds, p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }

        public Task<ImportRoomNotifyPushListPage> ImportRoomNotifySendAsync(string userId, string projectCd, string buildingCd, RoomNotifyPushImport rooms)
        {
            return _notifyRepository.ImportRoomNotifySendAsync(userId, projectCd, buildingCd, rooms);
        }
        public CommonListPage GetNotifySentPageByRoom(FilterInpNotifySend flt)
        {
            return _notifyRepository.GetNotifySentPageByRoom(flt);
        }
    }
}
