using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.App;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.Model;

namespace UNI.Resident.BLL.BusinessService.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class AppApartmentService : IAppApartmentService
    {
        private readonly IAppApartmentRepository _homeRepository;
        private readonly IStorageService _storageService;
        private readonly IFirebaseRepository _fbnotiRepository;
        protected readonly ILogger _logger;
        public AppApartmentService(
            IAppApartmentRepository homeRepository,
            IStorageService storageService,
            IFirebaseRepository fbnotiRepository,
            ILoggerFactory logger)
        {
            if (homeRepository != null)
                _homeRepository = homeRepository;
            _storageService = storageService;
            _fbnotiRepository = fbnotiRepository;
            _logger = logger.CreateLogger(GetType().Name);
        }
        #region app-apartment-reg
        public async Task SetApartmentRegAsync(string userId, HomApartmentReg reg)
        {
            await _homeRepository.SetApartmentRegAsync(userId, reg);
        }
        public async Task<HomApartmentPageHome> GetApartmentPageHomeAsync(string language)
        {
            return await _homeRepository.GetApartmentPageHomeAsync(language);
        }
        public async Task<homApartmentPage> GetApartmentListAsync(string userId)
        {
            return await _homeRepository.GetApartmentListAsync(userId);
        }
        public async Task SetApartmentMainAsync(HomApartmentStatus main)
        {
            await _homeRepository.SetApartmentMainAsync(main);
        }
        public async Task<homApartmentCartPage> GetApartmentCartsAsync(string userId)
        {
            return await _homeRepository.GetApartmentCartAsync(userId);
        }
        public async Task<homApartmentCartDetail> GetApartmentCartDetailAsync(string language, string roomCd)
        {
            return await _homeRepository.GetApartmentCartDetailAsync(language, roomCd);
        }
        
        public async Task<PageFamilyMember> GetPageFamilyMemberAsync(int? ApartmentId)
        {
            return await _homeRepository.GetPageFamilyMemberAsync(ApartmentId);
        }
        
        #endregion app-apartment-reg

        #region web-apartment
        //public async Task<HomApartmentPage> GetApartmentPageAsync(FilterBaseApartments filter)
        //{
        //    return await _homeRepository.GetApartmentPageAsync(filter);
        //}
        //public async Task<HomApartmentInfo> GetApartmentInfoAsync(long apartmentId)
        //{
        //    return await _homeRepository.GetApartmentInfoAsync(apartmentId);
        //}
        public async Task<List<HomApartmentRelation>> GetApartmentRationsAsync(string userId)
        {
            return await _homeRepository.GetApartmentRationsAsync(userId);
        }
        //public async Task<BaseValidate> SetFamilyMemberAsync(HomApartmentMemberSet customer)
        //{
        //    return await _homeRepository.SetFamilyMemberAsync(customer);
        //}
        public async Task<HomApartmentMemberGet> SetMemberProfileAsync(HomMemberProfileSet profile)
        {
            return await _homeRepository.SetMemberProfileAsync(profile);
        }
        public async Task<BaseValidate> SetFamilyMemberAuthAsync(HomMemberBase customer)
        {
            return await _homeRepository.SetFamilyMemberAuthAsync(customer);
        }
        public async Task SetFamilyMemberRejectAsync(HomMemberBase customer)
        {
            await _homeRepository.SetFamilyMemberRejectAsync(customer);
        }
        public async Task<HomApartmentMemberGet> GetFamilyMemberAsync(string custId, int apartmentId)
        {
            return await _homeRepository.GetFamilyMemberAsync(custId, apartmentId);
        }
        public async Task<BaseValidate> DeleteFamilyMemberAsync(string custId, int apartmentId)
        {
            return await _homeRepository.DeleteFamilyMemberAsync(custId, apartmentId);
        }
        
        #endregion web-apartment
        
    }
}
