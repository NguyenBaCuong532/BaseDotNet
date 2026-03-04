using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Model.Firestore;

namespace UNI.Resident.DAL.Interfaces
{
    public interface IFirebaseRepository
    {
       
        Task<bool> SendNotifyQueue<T>(CfgQueueNotify<T> notifyQueue, bool hasInbox);
        Task SetEventBills(List<fbEventServiceBill> bills);
        Task SetNotifyPush(AppNotifyTake1 noti);
        Task SetNotifyJobPush(NotifyJobTake noti);

        #region thread-reg
        Task SetThreadCreate(fbThread thread);
        Task SetThreadUser(fbThreadUserAdd id, fbThreadUser user, string old_userId);
        Task DelThreadUser(fbThreadUserAdd id);
        #endregion thread-reg
    }
}
