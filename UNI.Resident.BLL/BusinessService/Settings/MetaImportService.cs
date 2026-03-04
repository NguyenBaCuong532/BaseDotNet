using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.DAL.Interfaces.Settings;
using UNI.Resident.Model;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.Settings
{
    /// <summary>
    /// Class WorktimeService.
    /// <author>TH</author>
    /// <date>2015/12/02</date>
    /// </summary>
    public class MetaImportService : IMetaImportService
    {
        private readonly IMetaImportRepository _posRepository;
        public MetaImportService(
            IMetaImportRepository posRepository
            )
        {
            if (posRepository != null)
                _posRepository = posRepository;
        }

        public async Task<BaseValidate> DelImport(Guid impId)
        {
            return await _posRepository.DelImport(impId);
        }

        public async Task<byte[]> GetFileTemplateAsync(string import_type)
        {
            var val = typeof(ImportTemplateFiles).GetField(import_type, System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static)?.GetValue(null)?.ToString();
            var utils = new FlexcellUtils();
            var template = await System.IO.File.ReadAllBytesAsync($"templates/{val}");
            Dictionary<string, object> p = new Dictionary<string, object>();
            var fs = utils.CreateReport(template, ReportType.xlsx, new DataSet(), p);
            var fileBytes = fs.ReadAllBytes();
            fs.Dispose();
            fs.Close();
            return fileBytes;
        }

        public Task<CommonDataPage> GetImportPageAsync(FilterBase flt, string import_type)
        {
            return _posRepository.GetImportPageAsync(flt, import_type);
        }
    }
}
