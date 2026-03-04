using UNI.Resident.Model.VehiclePayment;
using UNI.Resident.Model.Common;
using System;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.DAL.Interfaces.CardVehicle
{
    public interface IVehiclePaymentRepository
    {
        #region Vehicle Payment Management
        
        /// <summary>
        /// Lấy danh sách thanh toán xe theo trang
        /// </summary>
        /// <param name="query">Tham số tìm kiếm và phân trang</param>
        /// <returns>Danh sách thanh toán xe đã phân trang</returns>
        Task<CommonDataPage> GetPageAsync(VehiclePaymentRequestModel query);
        
        /// <summary>
        /// Lấy thông tin chi tiết thanh toán xe
        /// </summary>
        /// <param name="paymentId">ID thanh toán</param>
        /// <param name="cardVehicleId">ID thẻ xe</param>
        /// <returns>Thông tin thanh toán xe</returns>
        Task<VehiclePaymentInfo> GetInfoAsync(Guid? paymentId, int? cardVehicleId = null, Guid? cardVehicleOid = null);
        
        /// <summary>
        /// Tạo bản nháp thanh toán xe
        /// </summary>
        /// <param name="draft">Thông tin bản nháp</param>
        /// <returns>Kết quả tạo bản nháp</returns>
        Task<VehiclePaymentInfo> SetDraftAsync(VehiclePaymentInfo draft);
        
        /// <summary>
        /// Cập nhật thông tin thanh toán xe
        /// </summary>
        /// <param name="info">Thông tin thanh toán</param>
        /// <returns>Kết quả cập nhật</returns>
        Task<BaseValidate> SetInfoAsync(VehiclePaymentInfo info);
        
        /// <summary>
        /// Xóa thanh toán xe
        /// </summary>
        /// <param name="paymentId">ID thanh toán</param>
        /// <returns>Kết quả xóa</returns>
        Task<BaseValidate> DeleteAsync(Guid paymentId);
        
        /// <summary>
        /// Duyệt thanh toán xe
        /// </summary>
        /// <param name="approve">Thông tin duyệt</param>
        /// <returns>Kết quả duyệt</returns>
        Task<BaseValidate> SetApproveAsync(VehiclePaymentApproveModel approve);
        
        #endregion
    }
}


