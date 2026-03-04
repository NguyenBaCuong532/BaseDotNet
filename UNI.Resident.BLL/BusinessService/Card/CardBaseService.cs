using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Card;
using UNI.Resident.DAL.Interfaces.Card;
using UNI.Resident.Model.Card;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.Card
{
    public class CardBaseService : ICardBaseService
    {
        private readonly ICardBaseRepository _repository;

        public CardBaseService(ICardBaseRepository cardTypeRepository)
        {
            _repository = cardTypeRepository;
        }

        public Task<CommonDataPage> GetCardBasePage(FilterBase filter, long startNum, long endNum, bool status)
        {
            return _repository.GetCardBasePage(filter, startNum, endNum, status);
        }

        public Task<BaseValidate> SetBaseClassify(CardClassificationInfo info)
        {
            return _repository.SetBaseClassify(info);
        }

        public Task<CardClassificationInfo> GetClassifyInfo(Guid? id)
        {
            return _repository.GetClassifyInfo(id);
        }

        public Task<BaseValidate> DeleteCardBase(string id)
        {
            return _repository.DeleteCardBase(id);
        }

        public async Task<BaseValidate<Stream>> GetCardBaseImportTemp()
        {
            try
            {
                var ds = await _repository.GetCardBaseImportTemp();
                var r = new FlexcellUtils();
                var template = await File.ReadAllBytesAsync($"templates/cards/import_card.xlsx");
                Dictionary<string, object> p = new Dictionary<string, object>();
                var report = r.CreateReport(template, ReportType.xlsx, ds, p);
                return new BaseValidate<Stream>(report);
            }
            catch (Exception ex)
            {
                return new BaseValidate<Stream>(null);
            }
        }
        public Task<ImportListPage> SetCardBaseImportAsync(CardImportSet cards)
        {
            return _repository.SetCardBaseImportAsync(cards);
        }
        public Task<List<CommonValue>> GetCardBaseList(string projectCd, Guid? oid, string filter)
        {
            return _repository.GetCardBaseList(projectCd, oid, filter);
        }

        public CommonViewInfo GetCardBaseFilter(string userId)
        {
            return _repository.GetCardBaseFilter(userId);
        }
    }
}
