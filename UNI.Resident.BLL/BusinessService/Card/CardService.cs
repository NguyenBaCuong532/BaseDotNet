using DocumentFormat.OpenXml.EMMA;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Utils;
//using SSG.DAL.Interfaces;

namespace UNI.Resident.BLL.BusinessService.Card
{
    public class CardService: ICardService
    {
        private readonly ICardRepository _repository;
        public CardService(
            ICardRepository repository)
        {
            if (repository != null)
                _repository = repository;
        }
        
        // thẻ xe thuộc căn hộ
        public async Task<CommonDataPage> GetCardPageAsync(FamilyCardRequestModel query)
        {
            return await _repository.GetCardPageAsync(query);
        }
        public async Task<FamilyCardInfo> GetCardInfoAsync(string CardCd, Guid? cardOid = null)
        {
            return await _repository.GetCardInfoAsync(CardCd, cardOid);
        }

        public async Task<BaseValidate> SetCardInfoAsync(FamilyCardInfo info)
        {
            return await _repository.SetCardInfoAsync(info);
        }
        public async Task<BaseValidate> DeleteCardAsync(string CardCd)
        {
            return await _repository.DeleteCardAsync(CardCd);
        }
        public async Task<BaseValidate> SetCardLockedAsync(string CardCd, int Status, string Reason, bool IsHardLock)
        {
            return await _repository.SetCardLockedAsync(CardCd, Status, Reason, IsHardLock);
        }
        // thẻ xe
        public async Task<CommonDataPage> GetVehicleCardPageAsync(VehicleCardRequestModel query)
        {
            return await _repository.GetVehicleCardPageAsync(query);
        }
        public async Task<VehicleCardInfo> GetVehicleCardInfoAsync(int? CardVehicleId, Guid? cardVehicleOid = null)
        {
            return await _repository.GetVehicleCardInfoAsync(CardVehicleId, cardVehicleOid);
        }

        public async Task<BaseValidate> SetVehicleCardInfoAsync(VehicleCardInfo info, string projectCd)
        {
            return await _repository.SetVehicleCardInfoAsync(info, projectCd);
        }
        public async Task<BaseValidate> SetVehicleLockedAsync(int CardVehicleId, int Status, Guid? cardVehicleOid = null)
        {
            return await _repository.SetVehicleLockedAsync(CardVehicleId, Status, cardVehicleOid);
        }

        /// <summary>
        /// Gửi yêu cầu đóng thẻ gửi xe
        /// </summary>
        /// <param name="inputParam"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetCardReturnRequest(CardVehicle_CardReturnRequest inputParam)
            => _repository.SetCardReturnRequest(inputParam);

        public async Task<VehicleCardInfo> GetVehiclePaymentByDayInfoAsync(string CardVehicleId, string StartDate, string EndDate, string ProjectCd)
        {
            return await _repository.GetVehiclePaymentByDayInfoAsync(CardVehicleId, StartDate, EndDate,ProjectCd);
        }

        public async Task<BaseValidate> SetVehiclePaymentByDayInfoAsync(VehicleCardInfo info)
        {
            return await _repository.SetVehiclePaymentByDayInfoAsync(info);
        }

        public async Task<BaseValidate> DeleteVehicleCardAsync(int cardVehicleId, Guid? cardVehicleOid = null)
        {
            return await _repository.DeleteVehicleCardAsync(cardVehicleId, cardVehicleOid);
        }

        public async Task<CardInfoV2> GetCardInfoV2(string RoomCd)
        {
            return await _repository.GetCardInfoV2(RoomCd);
        }

        public async Task<BaseValidate> SetCardInfoV2(CardInfoV2 info)
        {
            return await _repository.SetCardInfoV2(info);
        }

        public CommonViewInfo GetResidentVehicleFilter(string userId)
        {
            return _repository.GetResidentVehicleFilter(userId);
        }

        public async Task<CommonDataPage> GetResidentVehiclePage(ResidentVehicleRequestModel query)
        {
            return await _repository.GetResidentVehiclePage(query);
        }
        public CommonViewInfo GetResidentCardFilter(string userId)
        {
            return _repository.GetResidentCardFilter(userId);
        }

        public async Task<CommonDataPage> GetResidentCardPage(FilterCardResident query)
        {
            return await _repository.GetResidentCardPage(query);
        }

        public Task<CommonDataPage> GetGuestCardPageAsync(CardGuestFilter query)
        {
            return _repository.GetGuestCardPageAsync(query);
        }

        public Task<CommonViewInfo> GetInfoAsync(string cardType, string cardCode)
        {
            return _repository.GetInfoAsync(cardType, cardCode);
        }

        public Task<BaseValidate> SetGuestCardInfoAsync(CommonViewInfo info)
        {
            return _repository.SetGuestCardInfoAsync(info);
        }

        public Task<ImportListPage> ImportAsync(CardImportSet cards)
        {
            return _repository.ImportAsync(cards);
        }

        //public Task<CommonDataPage> GetCardBasePageAsync(FilterBase filter)
        //{
        //    return _repository.GetCardBasePageAsync(filter);
        //}

        //public Task<BaseValidate> GetCardBaseAsync(CardClassificationInfo info)
        //{
        //    return _repository.GetCardBaseAsync(info);
        //}

        //public Task<CardClassificationInfo> GetClassifyInfoAsync(string id)
        //{
        //    return _repository.GetClassifyInfoAsync(id);
        //}

        //public Task<BaseValidate> DeleteCardBaseAsync(string id)
        //{
        //    return _repository.DeleteCardBaseAsync(id);
        //}

        //public async Task<BaseValidate<Stream>> GetCardBaseImportTemp(string userId)
        //{
        //    try
        //    {
        //        var ds = await _repository.GetCardBaseImportTemp(userId);
        //        var r = new FlexcellUtils();
        //        var template = await File.ReadAllBytesAsync($"templates/cards/import_card.xlsx");
        //        Dictionary<string, object> p = new Dictionary<string, object>();
        //        var report = r.CreateReport(template, ReportType.xlsx, ds, p);
        //        return new BaseValidate<Stream>(report);
        //    }
        //    catch (Exception ex)
        //    {
        //        return new BaseValidate<Stream>(null);
        //    }
        //}
        public async Task<BaseValidate<Stream>> GetVehicleCardBaseImportTemp(string userId)
        {
            try
            {
               var ds = await _repository.GetVehicleCardBaseImportTemp(userId); 
                var r = new FlexcellUtils();
                var template = await File.ReadAllBytesAsync($"templates/cards/import_vehicle_card.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, ds, p) ;
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }

        public Task<ImportListPage> ImportVehicleAsync(CardVehicleImportSet cards)
        {
            return _repository.ImportVehicleAsync(cards);
        }

        public CommonViewInfo GetVehicleCardDailyFilter(string userId)
        {
            return _repository.GetVehicleCardDailyFilter(userId);
        }

        public async Task<CommonDataPage> GetVehicleCardDailyPage(VehicleCardDailyRequestModel query)
        {
            return await _repository.GetVehicleCardDailyPage(query);
        }
        public async Task<CommonDataPage> GetVehicleHistoryChange(VehicleHistoryChange query)
        {
            return await _repository.GetVehicleHistoryChange(query);
        }

        public async Task<BaseValidate> SetVehicleLockedWithReasonAsync(int cardVehicleId, int status, string reason, bool isHardLock, Guid? cardVehicleOid = null)
        {
            return await _repository.SetVehicleLockedWithReasonAsync(cardVehicleId, status, reason, isHardLock, cardVehicleOid);
        }

        public async Task<FamilyCardInfo> GetCardLockInfoAsync(string cardCd, Guid? cardOid = null)
        {
            return await _repository.GetCardLockInfoAsync(cardCd, cardOid);
        }

        public async Task<FamilyCardInfo> GetEditCardInfoAsync(string cardCd, Guid? cardOid = null)
        {
            return await _repository.GetEditCardInfoAsync(cardCd, cardOid);
        }

        public async Task<BaseValidate> SetEditCardInfoAsync(FamilyCardInfo info)
        {
            return await _repository.SetEditCardInfoAsync(info);
        }

        public async Task<VehicleCardInfo> GetVehicleCardDraftAsync(VehicleCardInfo info)
        {
            return await _repository.GetVehicleCardDraftAsync(info);
        }

        public Task<int> SetCardVehicleServiceAuth(HomVehicleServiceAuth card)
        {
            return _repository.SetCardVehicleServiceAuth(card);
        }

        public Task<CommonDataPage> GetVehicleCardServicePageAsync(VehicleCardRequestModel query)
        {
           return _repository.GetVehicleCardServicePageAsync(query);
        }
        /// <summary>
        /// Load form thanh toán / kích hoạt thẻ xe
        /// </summary>
        public Task<VehiclePaymentLoadFormInfo> GetVehiclePaymentLoadFormAsync(
    string userId,
    string clientId,
    string projectCd,
    Guid? paymentId,
    int cardVehicleId,
    Guid? cardVehicleOid = null)
        {
            return _repository.GetVehiclePaymentLoadFormAsync(cardVehicleId, paymentId, cardVehicleOid);
        }

        public async Task<BaseValidate> SetVehiclePaymentSubmitAsync(
    string userId,
    string clientId,
    string projectCd,
    VehiclePaymentSubmitRequest request)
        {
            return await _repository.SetVehiclePaymentSubmitAsync(
                userId,
                projectCd,
                request
            );
        }

    }
}
