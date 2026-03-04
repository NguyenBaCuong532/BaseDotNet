using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Receipt;
using UNI.Resident.Model.Request;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Interfaces.Request
{
    public interface IServiceRepository
    {
        Task<BaseValidate> SetServiceStopPushAsync(ApartmentsDto apartments, string projectcode);

        // Cleaning service methods
        Task<RequestInfo> GetCleaningServiceInfo(string? requestId);
        CommonViewInfo GetCleaningServiceFilter(string userId);
        Task<CommonDataPage> GetCleaningServicePage(RequestModel query);
        Task<ResponseList<List<RequestProcessGet>>> GetCleaningServiceProcessPageAsync(ProcessFilter query);
    }
}
