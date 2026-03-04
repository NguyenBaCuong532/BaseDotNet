using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.DAL.Interfaces.Apartment;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.Apartment
{
    public class HouseholdService: IHouseholdService
    {
        private readonly IHouseholdRepository _apartmentRepository;
        public HouseholdService(
            IHouseholdRepository apartmentRepository)
        {
            if (apartmentRepository != null)
                _apartmentRepository = apartmentRepository;
        }
        
        // Hộ khẩu
        public Task<CommonViewInfo> GetHouseholdFilter(string userId)
        {
            return _apartmentRepository.GetHouseholdFilter(userId);
        }
        public async Task<CommonDataPage> GetHouseholdPageByApartment(HouseholdRequestModel query)
        {
            return await _apartmentRepository.GetHouseholdPageByApartment(query);
        }
        public async Task<CommonDataPage> GetHouseholdPage(HouseholdRequestModel1 query)
        {
            return await _apartmentRepository.GetHouseholdPage(query);
        }
        public async Task<HouseholdInfo> GetHouseholdInfo(string CustId, int? ApartmentId, Guid? apartOid, Guid? Oid)
        {
            return await _apartmentRepository.GetHouseholdInfo(CustId, ApartmentId, apartOid, Oid);
        }

        public async Task<BaseValidate> SetHouseholdInfo(HouseholdInfo info)
        {
            return await _apartmentRepository.SetHouseholdInfo(info);
        }

    }
}
