using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model.Invoice;

namespace UNI.Resident.DAL.Repositories.Notify
{
    public class TaskRepository: UniBaseRepository, ITaskRepository
    {

        public TaskRepository(IUniCommonBaseRepository common) : base(common)
        {
        }

        public async Task<List<MessageSend>> GetMessagesBySend()
        {
            const string storedProcedure = "sp_resident_message_bySend";
            return await GetListAsync<MessageSend>(storedProcedure, null);
        }
        public async Task SetMessageSent(MessageSent sent)
        {
            const string storedProcedure = "sp_resident_message_sent";
            await SetAsync(storedProcedure, sent);
        }

        public async Task<List<EmailModel>> GetEmailBySend(string id)
        {
            const string storedProcedure = "sp_resident_email_bySend";
            return await GetMultipleAsync<List<EmailModel>>(storedProcedure, new { id }, async reader =>
            {
                var data = reader.Read<EmailModel>().ToList();
                var atts = reader.Read<EmailAttach>().ToList();
                if (data != null && data.Count > 0)
                {
                    foreach (var d in data)
                    {
                        d.attachUrls = atts.Where(a => a.id == d.id).ToList();
                    }
                }
                return data;
            });
        }
        public async Task SetEmailSent(EmailSent sent)
        {
            const string storedProcedure = "sp_resident_email_sent";
            await SetAsync(storedProcedure, sent);
        }
        public async Task<List<NotifyJobTake>> GetNotifyByPush(string id)
        {
            const string storedProcedure = "sp_res_notify_bySend";
            return await GetMultipleAsync<List<NotifyJobTake>>(storedProcedure, new { id }, async reader =>
            {
                var data = reader.Read<NotifyJobTake>().ToList();
                var pushNotifyUsers = reader.Read<PushNotifyUser>().ToList();
                if (data != null && data.Count > 0)
                {
                    foreach (var d in data)
                    {
                        d.appUsers = pushNotifyUsers.Where(a => a.id == d.id).ToList();
                    }
                }
                return data;
            });
        }
        public async Task SetNotifySent(NotifyJobTake sent)
        {
            const string storedProcedure = "sp_res_notify_sent";
            await SetAsync(storedProcedure, sent);
        }
        public async Task TakeNotifySend(NotifyJobTake sent)
        {
            const string storedProcedure = "sp_res_notify_set";
            await SetAsync(storedProcedure, sent);
        }

        public async Task<List<ServiceBill>> GetServiceBillByJobs(string receiveIds)
        {
            const string storedProcedure = "sp_res_service_receivable_bill_by_job";
            return await GetListAsync<ServiceBill>(storedProcedure, new {receiveIds});
        }

        public async Task<int> SetServiceBill(ServiceBill bill)
        {
            const string storedProcedure = "sp_res_service_receivable_bill_set";
            return await GetFirstOrDefaultAsync<int>(storedProcedure, new { bill.ReceiveId, bill.BillUrl, bill.BillViewUrl });
        }
        public async Task<int> TakeMessage(MessageSend mess)
        {
            const string storedProcedure = "sp_resident_message_set";
            return await GetFirstOrDefaultAsync<int>(storedProcedure,
                new
                {
                    mess.messageId,
                    mess.phone,
                    mess.custName,
                    mess.message,
                    mess.scheduleAt,
                    mess.brandName,
                    mess.isSent,
                    mess.custId,
                    mess.sourceId,
                    mess.partner,
                    mess.remart
                });
        }
        
        public async Task<int> TakeSendMail(EmailBase email)
        {
            const string storedProcedure = "sp_resident_email_set";
            return await base.GetFirstOrDefaultAsync<int>(storedProcedure, new { email.To, email.Cc, email.Bcc, email.SendBy, email.Subject, email.Contents, email.BodyType, email.Attachs, email.SendType, email.SendName, email.SendingTime, email.custId, email.isSent, email.sourceId, email.id, email.source_key });
        }
    }
}
