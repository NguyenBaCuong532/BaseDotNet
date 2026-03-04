using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;

namespace SSG.Resident.DAL.Interfaces.App
{

    public interface IMarketingRepository
    {
        #region App Marketing
        mktVoucherGet GetVoucher(string userId, string vou_Id);
        ResponseList<List<mktVoucher>> GetVoucherPage(FilterBase2 filter);
        #endregion App Marketing

        #region Web core
        mktVoucherInfoPage GetVoucherInfoPage(FilterBase filter);
        mktVoucherInfo GetVoucherInfo(string userId,  long vou_id);
        Task SetVoucherInfo(string userId, mktVoucherInfo voucher);
        List<mktVoucherShort> GetVoucherInfoList(string userId, string filter);
        mktVoucherOpenPage GetVoucherOpenPage(FilterBase1 filter);
        mktVoucherOpenInfo GetVoucherOpen(string userId,  long vou_open_id, long vou_id, string provider_cd);
        Task<BaseValidate> SetVoucherOpen(string userId, mktVoucherOpenInfo vouOpen);
        mktVoucherTranPage GetVoucherTranPage(FilterBase1 filter);
        mktVoucherTranInfo GetVoucherTran(string userId, long vou_tnx_id);
        Task<BaseValidate> SetVoucherTran(string userId, mktVoucherTranInfo vouTran);
        #endregion Web core
    }
}
