using SSG.Resident.BLL.BusinessInterfaces.App;
using SSG.Resident.DAL.Interfaces.App;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Marketing;

namespace SSG.Resident.BLL.BusinessService.App
{
    /// <summary>
    /// Class Marketing Service.
    /// <author>Duongpx</author>
    /// <date>2020/12/02</date>
    /// </summary>
    public class MarketingService : IMarketingService
    {
        private readonly IMarketingRepository _marketingRepository;
       
        public MarketingService(IMarketingRepository marketingRepository)
        {
            if (marketingRepository != null)
                _marketingRepository = marketingRepository;
        }
        #region App Marketing
        public mktVoucherGet GetVoucher(string userId, string vou_Id)
        {
            return _marketingRepository.GetVoucher(userId, vou_Id);
        }
        public ResponseList<List<mktVoucher>> GetVoucherPage(FilterBase2 filter)
        {
            return _marketingRepository.GetVoucherPage(filter);
        }
        #endregion App Marketing

        #region Web core
        public mktVoucherInfoPage GetVoucherInfoPage(FilterBase filter)
        {
            return _marketingRepository.GetVoucherInfoPage(filter);
        }
        public mktVoucherInfo GetVoucherInfo(string userId,  long vou_id)
        {
            return _marketingRepository.GetVoucherInfo(userId, vou_id);
        }
        public Task SetVoucherInfo(string userId, mktVoucherInfo voucher)
        {
            return _marketingRepository.SetVoucherInfo(userId, voucher);
        }
        public List<mktVoucherShort> GetVoucherInfoList(string userId, string filter)
        {
            return _marketingRepository.GetVoucherInfoList(userId, filter);
        }
        public mktVoucherOpenPage GetVoucherOpenPage(FilterBase1 filter)
        {
            return _marketingRepository.GetVoucherOpenPage(filter);
        }
        public mktVoucherOpenInfo GetVoucherOpen(string userId,  long vou_open_id, long vou_id, string provider_cd)
        {
            return _marketingRepository.GetVoucherOpen(userId, vou_open_id, vou_id, provider_cd);
        }
        public Task<BaseValidate> SetVoucherOpen(string userId, mktVoucherOpenInfo vouOpen)
        {
            return _marketingRepository.SetVoucherOpen(userId, vouOpen);
        }
        public mktVoucherTranPage GetVoucherTranPage(FilterBase1 filter)
        {
            return _marketingRepository.GetVoucherTranPage(filter);
        }
        public mktVoucherTranInfo GetVoucherTran(string userId, long vou_tnx_id)
        {
            return _marketingRepository.GetVoucherTran(userId, vou_tnx_id);
        }
        public Task<BaseValidate> SetVoucherTran(string userId, mktVoucherTranInfo vouTran)
        {
            return _marketingRepository.SetVoucherTran(userId, vouTran);
        }

        #endregion Web core
    }
}
