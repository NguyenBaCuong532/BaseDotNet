using Google.Cloud.Firestore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Model.Firestore;
using UNI.Resident.DAL.Interfaces;

namespace UNI.Resident.DAL.Repositories
{
    public class FirebaseRepository : IFirebaseRepository
    {
        private readonly ILogger<FirebaseRepository> _logger;
        private readonly AppSettings _appSettings;

        public FirebaseRepository(ILogger<FirebaseRepository> logger, IOptions<AppSettings> appSettings, IConfiguration configuration)
        {
            _logger = logger;
            _appSettings = appSettings.Value;
        }
        #region notify-event
        public async Task<bool> SendNotifyQueue<T>(CfgQueueNotify<T> notifyQueue, bool hasInbox = true)
        {
            try
            {
                _logger.LogInformation($"NotifyInfo: { JsonConvert.SerializeObject(notifyQueue) }");
                //string projectId = Utils.GetAppSettingByKey<string>("AppSettings:ProjectId");
                var queueRef = Global.Db.Collection("notifications_queue").Document();
                if (notifyQueue.Users != null && notifyQueue.Users.Count > 0)
                    await queueRef.SetAsync(notifyQueue, SetOptions.MergeAll);

                return await Task.FromResult(true);
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        public async Task SetNotifyPush(AppNotifyTake1 noti)
        {
            try
            {
                var notifyQueue = noti.GetNotifyQueue(new CfgEventNotify 
                { 
                    moduleId = noti.external_key,
                    n_id = noti.n_id,
                    notiType = noti.notiType,
                    //pushEvent = noti.external_event,
                    //savePush = false,
                    external_param = noti.external_param
                });
                _logger.LogError($"notifications_queue: {noti}");
                var Db = FirestoreDb.Create(_appSettings.ProjectId);
                var queueRef = Db.Collection("notifications_queue").Document();                
                if (notifyQueue.Users != null && notifyQueue.Users.Count > 0)
                {
                    await queueRef.SetAsync(notifyQueue, SetOptions.MergeAll);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                //throw;
            }
        }
        public async Task SetNotifyJobPush(NotifyJobTake noti)
        {
            try
            {
                var notifyQueue = noti.GetNotifyQueue(new CfgEventNotify
                {
                    moduleId = noti.external_key,
                    //n_id = noti.n_id,
                    notiType = noti.notiType,
                    external_param = noti.external_param
                });
                _logger.LogError($"notifications_queue: {noti}");
                var Db = FirestoreDb.Create(_appSettings.ProjectId);
                var queueRef = Db.Collection("notifications_queue").Document();
                if (notifyQueue.Users != null && notifyQueue.Users.Count > 0)
                {
                    var rsNoti = await queueRef.SetAsync(notifyQueue, SetOptions.MergeAll);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        
        #endregion notify-event

        public async Task SetEventBills(List<fbEventServiceBill> bills)
        {
            try
            {
                var queueRef = Global.Db.Collection("events").Document();
                foreach (var b in bills)
                {
                    await queueRef.SetAsync(b, SetOptions.MergeAll);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                //throw;
            }
        }
               
        #region thread-reg
        public async Task SetThreadCreate(fbThread thread)
        {
            try
            {
                thread.createdDt = TimeZoneInfo.ConvertTimeToUtc(DateTime.Now);
                if (thread.Customer == null)
                    thread.Customer = new fbThreadCust { };
                if (thread.Saler == null)
                    thread.Saler = new fbThreadUser { };
                if (thread.Supporter == null)
                    thread.Supporter = new fbThreadUser { };
                if (thread.Ticket == null)
                    thread.Ticket = new fbThreadTicket { sub_prod_cd = thread.sub_prod_cd, Status = thread.Status, request_by = thread.cust_userId,Id = Guid.NewGuid().ToString() };
                thread.typing = new List<string>();

                var queueRef = Global.Db.Collection("threads").Document(thread.id.ToString());
                await queueRef.SetAsync(thread, SetOptions.MergeAll);
                foreach(var user in thread.Users)
                {
                    var docuser = Global.Db.Collection("threads").Document(thread.id.ToString()).Collection("users").Document(user.userId);
                    user.createdDt = TimeZoneInfo.ConvertTimeToUtc(DateTime.Now);
                    await docuser.SetAsync(user, SetOptions.MergeAll);
                }    
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        
        public async Task SetThreadUser(fbThreadUserAdd id, fbThreadUser user, string old_userId)
        {
            try
            {
                var queueUser = Global.Db.Collection("threads").Document(id.thread_id).Collection("users").Document(user.userId);
                await queueUser.SetAsync(user, SetOptions.MergeAll);
                if (old_userId != null && old_userId != string.Empty)
                {
                    var delUser = Global.Db.Collection("threads").Document(id.thread_id).Collection("users").Document(old_userId);
                    await delUser.DeleteAsync();
                }
                if (id.role == "saler")
                {
                    var docRef = Global.Db.Collection("threads").Document(id.thread_id);
                    fbThread thr = new fbThread
                    {
                        Saler = user
                    };
                    await docRef.SetAsync(thr);
                } 
                else if (id.role == "supporter")
                {
                    var docRef = Global.Db.Collection("threads").Document(id.thread_id);
                    fbThread thr = new fbThread
                    {
                        Supporter = user
                    };
                    await docRef.SetAsync(thr);
                }
                
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        public async Task DelThreadUser(fbThreadUserAdd id)
        {
            try
            {
                var delUser = Global.Db.Collection("threads").Document(id.thread_id).Collection("users").Document(id.userId);
                await delUser.DeleteAsync();
                if (id.role == "saler")
                {
                    var docRef = Global.Db.Collection("threads").Document(id.thread_id);
                    fbThread thr = new fbThread
                    {
                        Saler = new fbThreadUser { }
                    };
                    await docRef.SetAsync(thr);
                }
                else if (id.role == "supporter")
                {
                    var docRef = Global.Db.Collection("threads").Document(id.thread_id);
                    fbThread thr = new fbThread
                    {
                        Supporter = new fbThreadUser { }
                    };
                    await docRef.SetAsync(thr);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"{ex}");
                throw;
            }
        }
        #endregion thread-reg
    }
}
