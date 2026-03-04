using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface IAppCardService
    {
        #region app-card-reg
        Task<PageFamilyCard> GetPageFamilyCardAsync(int? ApartmentId);
        Task<HomCardService> GetCardDetailAsync(string cardCd);
        Task<List<HomCardType>> GetCardTypesAsync();
        Task<long> SetCardRegisterAsync(HomCardRegSet cardSet);
        Task<BaseValidate> DeleteCardAsync(string cardCd);
        //Task<BaseValidate> SetCard(HomCardSet cardSet);
        Task<BaseValidate> SetCardLostAsync(HomCardBase card);
        Task SetCardLockedAsync(HomCardLock card);

        #endregion web-card-reg
        
        #region web-vehicle-reg
        Task<List<HomVehicleType>> GetVehicleTypesAsync();
        Task<BaseValidate> SetCardServiceVehicleAsync(HomServiceVehicleSet vehicle);
        #endregion web-vehicle-reg

    }
}
