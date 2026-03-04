using UNI.Resident.Model.Invoice;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Model;

namespace UNI.Resident.DAL.Interfaces.Notify
{
    public interface ITaskRepository
    {
        Task<List<MessageSend>> GetMessagesBySend();
        Task SetMessageSent(MessageSent sent);

        Task<List<EmailModel>> GetEmailBySend(string id);
        Task<List<NotifyJobTake>> GetNotifyByPush(string id);
        Task SetEmailSent(EmailSent sent);
        Task SetNotifySent(NotifyJobTake sent);
        Task TakeNotifySend(NotifyJobTake sent);
        Task<List<ServiceBill>> GetServiceBillByJobs(string receiveIds);
        Task<int> SetServiceBill(ServiceBill bill);
        Task<int> TakeMessage(MessageSend mess);
        Task<int> TakeSendMail(EmailBase email);
    }
}
