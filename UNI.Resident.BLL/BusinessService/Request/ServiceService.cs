using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Request;
using UNI.Resident.DAL.Interfaces.Request;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Receipt;
using UNI.Resident.Model.Request;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.Request
{
    public class ServiceService : IServiceService
    {
        private readonly IServiceRepository _serviceRepository;

        public ServiceService(IServiceRepository serviceRepository)
        {
            _serviceRepository = serviceRepository;
        }

        public Task<BaseValidate> SetServiceStopPushAsync(ApartmentsDto apartments, string projectcode)
        {
            return _serviceRepository.SetServiceStopPushAsync(apartments, projectcode);
        }

        public Task<RequestInfo> GetCleaningServiceInfo(string? requestId)
        {
            return _serviceRepository.GetCleaningServiceInfo(requestId);
        }

        public CommonViewInfo GetCleaningServiceFilter(string userId)
        {
            return _serviceRepository.GetCleaningServiceFilter(userId);
        }

        public Task<CommonDataPage> GetCleaningServicePage(RequestModel query)
        {
            return _serviceRepository.GetCleaningServicePage(query);
        }

        public Task<ResponseList<List<RequestProcessGet>>> GetCleaningServiceProcessPageAsync(ProcessFilter query)
        {
            return _serviceRepository.GetCleaningServiceProcessPageAsync(query);
        }
    }
}
