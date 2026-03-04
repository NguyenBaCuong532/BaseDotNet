using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.DAL.Interfaces.Request;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Receipt;
using UNI.Resident.Model.Request;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Repositories.Request
{
    public class ServiceRepository : UniBaseRepository, IServiceRepository
    {
        private readonly IFirebaseRepository _fbRepository;
        private readonly INotifyRepository _notifyRepository;

        public ServiceRepository(IUniCommonBaseRepository common,
            IFirebaseRepository fbRepository,
            INotifyRepository notifyRepository) : base(common)
        {
            _fbRepository = fbRepository;
            _notifyRepository = notifyRepository;
        }
        #region service_request
        public async Task<BaseValidate> SetServiceStopPushAsync(ApartmentsDto apartments, string projectcode)
        {
            const string storedProcedure = "sp_res_service_stop_push_kafka_v3";
            return await GetMultipleAsync<BaseValidate>(storedProcedure, param =>
            {
                param.Add("@projectcode", projectcode);
                param.Add("@apartmentIds", string.Join(",", apartments.ApartmentIds));
                return param;
            }, async result =>
            {
                var data = result.ReadFirstOrDefault<BaseValidate>();
                if (data.valid)
                {
                    var pushRuns = result.Read<PushNotifyRun>();
                    if (pushRuns != null)
                    {
                        foreach (var pushRun in pushRuns)
                        {
                            pushRun.ids = new List<string>();
                            await _notifyRepository.SendToKafka(pushRun);
                        }
                    }
                }
                return (data);
            });
        }
        #endregion service_request

        #region cleaning_service
        public async Task<RequestInfo> GetCleaningServiceInfo(string? requestId)
        {
            const string storedProcedure = "sp_res_cleaning_service_field";
            return await GetFieldsAsync<RequestInfo>(storedProcedure, new { RequestId = requestId });
        }

        public CommonViewInfo GetCleaningServiceFilter(string userId)
        {
            const string storedProcedure = "sp_res_cleaning_service_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { userId }).Result;
        }

        public async Task<CommonDataPage> GetCleaningServicePage(RequestModel query)
        {
            const string storedProcedure = "sp_res_cleaning_service_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ProjectCd, query.Status, query.IsNow, query.fromDate, query.toDate });
        }

        public async Task<ResponseList<List<RequestProcessGet>>> GetCleaningServiceProcessPageAsync(ProcessFilter query)
        {
            const string storedProcedure = "sp_res_cleaning_service_process_page";
            return await GetMultipleAsync<ResponseList<List<RequestProcessGet>>>(storedProcedure, param =>
            {
                param.Add("@Offset", query.offSet);
                param.Add("@PageSize", query.pageSize);
                param.Add("@RequestId", query.RequestId);
                param.Add("@Filter", query.filter);
                param.Add("@Total", 0, System.Data.DbType.Int64, System.Data.ParameterDirection.InputOutput);
                param.Add("@TotalFiltered", 0, System.Data.DbType.Int64, System.Data.ParameterDirection.InputOutput);
                return param;
            }, async result =>
            {
                var processes = (await result.ReadAsync<RequestProcessGet>()).ToList();
                var attachments = (await result.ReadAsync<RequestAttachment>()).ToList();
                processes.ForEach(x => x.Attachments = attachments.Where(a => a.ProcessId == x.ProcessId).ToList());
                return new ResponseList<List<RequestProcessGet>>(processes, 0, 0);
            });
        }
        #endregion cleaning_service
    }
}
