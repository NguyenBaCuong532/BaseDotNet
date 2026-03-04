using System;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Card;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Card
{
    public interface ICardService
    {
        #region web-apartment
        // QL thẻ thuộc căn hộ
        Task<CommonDataPage> GetCardPageAsync(FamilyCardRequestModel query);
        Task<FamilyCardInfo> GetCardInfoAsync(string CardCd, Guid? cardOid = null);
        Task<BaseValidate> SetCardInfoAsync(FamilyCardInfo info);
        Task<BaseValidate> DeleteCardAsync(string CardCd);
        Task<BaseValidate> SetCardLockedAsync(string CardCd, int Status, string Reason, bool IsHardLock);//Mở/Khóa thẻ
        // Thêm mới thẻ: Thẻ căn hộ, thẻ xe, thẻ tín dụng
        Task<CardInfoV2> GetCardInfoV2(string RoomCd);
        Task<BaseValidate> SetCardInfoV2(CardInfoV2 info);
        // QL thẻ xe
        Task<CommonDataPage> GetVehicleCardPageAsync(VehicleCardRequestModel query);
        Task<VehicleCardInfo> GetVehicleCardInfoAsync(int? CardVehicleId, Guid? cardVehicleOid = null);
        Task<BaseValidate> SetVehicleCardInfoAsync(VehicleCardInfo info, string projectCd);
        Task<BaseValidate> SetVehicleLockedAsync(int CardVehicleId, int Status, Guid? cardVehicleOid = null);

        /// <summary>
        /// Gửi yêu cầu đóng thẻ gửi xe
        /// </summary>
        /// <param name="inputParam"></param>
        /// <returns></returns>
        Task<BaseValidate> SetCardReturnRequest(CardVehicle_CardReturnRequest inputParam);

        Task<VehicleCardInfo> GetVehiclePaymentByDayInfoAsync(string CardVehicleId, string StartDate, string EndDate, string ProjectCd);// tính gia hạn thẻ
        Task<BaseValidate> SetVehiclePaymentByDayInfoAsync(VehicleCardInfo info);// cập nhật gia hạn thẻ
        Task<BaseValidate> DeleteVehicleCardAsync(int cardVehicleId, Guid? cardVehicleOid = null); // Xóa thẻ
        // xe cư dân
        CommonViewInfo GetResidentVehicleFilter(string userId);
        Task<CommonDataPage> GetResidentVehiclePage(ResidentVehicleRequestModel query);
        // thẻ cư dân
        CommonViewInfo GetResidentCardFilter(string userId);
        Task<CommonDataPage> GetResidentCardPage(FilterCardResident query);
        Task<CommonDataPage> GetGuestCardPageAsync(CardGuestFilter query);
        Task<CommonViewInfo> GetInfoAsync(string cardType, string cardCode);
        Task<BaseValidate> SetGuestCardInfoAsync(CommonViewInfo info);
        Task<ImportListPage> ImportAsync(CardImportSet cards);
        //Task<CommonDataPage> GetCardBasePageAsync(FilterBase filter);
        //Task<BaseValidate> GetCardBaseAsync(CardClassificationInfo info);
        //Task<CardClassificationInfo> GetClassifyInfoAsync(string id);
        //Task<BaseValidate> DeleteCardBaseAsync(string id);
        //// import ds thẻ trong QL kho thẻ
        //Task<BaseValidate<Stream>> GetCardBaseImportTemp(string userId);
        Task<BaseValidate<Stream>> GetVehicleCardBaseImportTemp(string userId);
        // thẻ lượt
        Task<ImportListPage> ImportVehicleAsync(CardVehicleImportSet cards);
        CommonViewInfo GetVehicleCardDailyFilter(string userId);
        Task<CommonDataPage> GetVehicleCardDailyPage(VehicleCardDailyRequestModel query);
        Task<CommonDataPage> GetVehicleHistoryChange(VehicleHistoryChange query);
        Task<BaseValidate> SetVehicleLockedWithReasonAsync(int cardVehicleId, int status, string reason, bool isHardLock, Guid? cardVehicleOid = null);
        Task<FamilyCardInfo> GetCardLockInfoAsync(string cardCd, Guid? cardOid = null);
        Task<FamilyCardInfo> GetEditCardInfoAsync(string cardCd, Guid? cardOid = null);
        Task<BaseValidate> SetEditCardInfoAsync(FamilyCardInfo info);
        Task<VehicleCardInfo> GetVehicleCardDraftAsync(VehicleCardInfo info);
        Task<int> SetCardVehicleServiceAuth(HomVehicleServiceAuth card);
        Task<CommonDataPage> GetVehicleCardServicePageAsync(VehicleCardRequestModel query);
        /// <summary>
        /// Load form thanh toán / kích hoạt thẻ xe
        /// </summary>
        Task<VehiclePaymentLoadFormInfo> GetVehiclePaymentLoadFormAsync(
            string userId,
            string clientId,
            string projectCd,
            Guid? paymentId,
            int cardVehicleId,
            Guid? cardVehicleOid = null
        );
        /// <summary>
        /// Xác nhận thanh toán tháng đầu và cập nhật trạng thái thẻ xe
        /// </summary>
        Task<BaseValidate> SetVehiclePaymentSubmitAsync(
            string userId,
            string clientId,
            string projectCd,
            VehiclePaymentSubmitRequest request
        );



        #endregion
    }
}
