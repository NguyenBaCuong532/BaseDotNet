using UNI.Resident.Model.Invoice;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.Notify
{
    public interface ITaskService
    {
        Task<List<MessageSend>> GetMessagesBySend();
        Task SetMessageSent(MessageSent sent);
        Task<MessageRespone> TakeMessage(MessageSend mess);
        Task<List<EmailModel>> GetEmailBySend(string id);
        Task<List<NotifyJobTake>> GetNotifyByPush(string id);
        Task SetEmailSent(EmailSent sent);
        Task<BaseValidate> TakeMailSend(EmailModel email);
        Task SetNotifySent(NotifyJobTake sent);
        Task TakeNotifySend(NotifyJobTake sent);
        Task<List<ServiceBill>> GetServiceBillByJobs(string receiveIds);
        Task<string> SetServiceBill(ServiceBill bill);

    }
}
