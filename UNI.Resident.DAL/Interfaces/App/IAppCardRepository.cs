using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;

namespace UNI.Resident.DAL.Interfaces.App
{
    public interface IAppCardRepository
    {
        #region app-card-reg
        Task<PageFamilyCard> GetPageFamilyCardAsync(int? ApartmentId);
        Task<HomCardService> GetCardDetailAsync(string cardCd);
        Task<List<HomCardType>> GetCardTypesAsync();
        Task<long> SetCardRegisterAsync(HomCardRegSet cardSet);
        Task<BaseValidate> DeleteCardAsync(string cardCd);
        Task<BaseValidate> SetCardLostAsync(HomCardBase card);
        Task SetCardLockedAsync(HomCardLock card);
        #endregion web-card-reg

        #region web-vehicle-reg
        Task<List<HomVehicleType>> GetVehicleTypesAsync();
        Task<BaseValidate> SetCardServiceVehicleAsync(HomServiceVehicleSet vehicle);
        #endregion web-vehicle-reg
    }
}
