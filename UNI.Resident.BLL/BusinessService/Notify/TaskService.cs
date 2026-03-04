using UNI.Resident.BLL.BusinessInterfaces.Notify;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Invoice;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model.Invoice;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.HelperService;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Utils;
using FluentEmail.Core.Interfaces;
using UNI.Model;
using UNI.Resident.DAL.Repositories.Notify;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using System.IO;
using UNI.Model.Email;
using System.Net.Http;
using System.Text.RegularExpressions;
using System.Text;

namespace UNI.Resident.BLL.BusinessService.Notify
{
    public class TaskService : ITaskService
    {
        private readonly ITaskRepository _taskRepository;
        private readonly IFirebaseRepository _fbnotiRepository;
        private readonly IFeeServiceRepository _feeServiceRepository;
        private readonly IApiSenderService _sender;
        public TaskService(ITaskRepository taskRepository,
            IFirebaseRepository fbnotiRepository,
            IApiSenderService sender,
            IFeeServiceRepository feeServiceRepository)
        {
            if (taskRepository != null)
                _taskRepository = taskRepository;
            _fbnotiRepository = fbnotiRepository;
            _feeServiceRepository = feeServiceRepository;
            _sender = sender;
        }
        public async Task<List<MessageSend>> GetMessagesBySend()
        {
            return await _taskRepository.GetMessagesBySend();
        }
        public Task SetMessageSent(MessageSent sent)
        {
            return _taskRepository.SetMessageSent(sent);
        }

        public async Task<List<EmailModel>> GetEmailBySend(string id)
        {
            return await _taskRepository.GetEmailBySend(id);
        }
        public async Task<List<NotifyJobTake>> GetNotifyByPush(string id)
        {
            return await _taskRepository.GetNotifyByPush(id);
        }
        public Task SetEmailSent(EmailSent sent)
        {
            return _taskRepository.SetEmailSent(sent);
        }
        public Task SetNotifySent(NotifyJobTake sent)
        {
            return _taskRepository.SetNotifySent(sent);
        }
        public Task TakeNotifySend(NotifyJobTake sent)
        {
            return _taskRepository.TakeNotifySend(sent);
        }

        public async Task<List<ServiceBill>> GetServiceBillByJobs(string receiveIds)
        {
            return await _taskRepository.GetServiceBillByJobs(receiveIds);
        }

        public async Task<MessageRespone> TakeMessage(MessageSend mess)
        {
            if (mess.partner == null)
                mess.partner = "iris";
            var response = await _sender.SendSmsAs(mess);
            mess.isSent = true;
            await _taskRepository.TakeMessage(mess);
            return response;

        }
        public async Task<BaseValidate> TakeMailSend(EmailModel email)
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
                await _taskRepository.TakeSendMail(email);
                return new BaseValidate { valid = true };
            }
            catch (Exception ex)
            {
                //_logger.LogError(ex.StackTrace);
                return new BaseValidate { valid = false, messages = ex.Message };
            }
        }
        public async Task<string> SetServiceBill(ServiceBill bill)
        {
            var data = await _feeServiceRepository.ApartmentFeeStreamNew(ReportType.pdf, bill.ReceiveId);
            Google.Apis.Storage.v1.Data.Object pathfile = null;
            var pfile = $"Bill/{data.folderName}/{DateTime.Now.ToString("yyyyMM")}/{data.fileName}-{bill.ReceiveId}.pdf";
            //GoogleDriverBaseService baseService = new GoogleDriverBaseService();
            //DriveService driveService = baseService.GetService3();
            //GoogleDriverHomeBillService _googleDriverService = new GoogleDriverHomeBillService();
            if (data != null && data.stream != null)
            {
                //var result = _googleDriverService.UploadBilFile(driveService, new ggDriverFileStream
                //{
                //    documentType = 1,
                //    fileName = data.fileName,
                //    stream = data.stream,
                //    mimeType = data.mimeType,
                //    folderName = data.folderName,
                //    dDate = data.dDate
                //});

                var bucket = "sunshine-app-production.appspot.com";
                pathfile = await FireBaseServices.UploadFile(data.stream, $"{pfile}", app: "s-service", bucket: bucket);
                var urlfile = pathfile.MediaLink.Replace("https://storage.googleapis.com/download/storage/v1/b/sunshine-app-production.appspot.com/o/", "https://cdn.sunshineapp.vn/");
                bill.BillUrl = urlfile; //result.WebContentLink;
                bill.BillViewUrl = urlfile; // result.WebViewLink;
                await _taskRepository.SetServiceBill(bill);
                return bill.BillUrl;
            }
            else
            {
                return null;
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
    }
}
