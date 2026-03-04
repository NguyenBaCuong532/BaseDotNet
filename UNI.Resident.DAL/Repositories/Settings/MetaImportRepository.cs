using System;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces.Settings;

namespace UNI.Resident.DAL.Repositories.Settings
{
    /// <summary>
    /// Worktime Repository
    /// </summary>
    /// Author: 
    /// CreatedDate: 16/11/2016 2:07 PM
    /// <seealso cref="IMetaImportRepository" />
    public class MetaImportRepository : UniBaseRepository, IMetaImportRepository
    {
        public MetaImportRepository(IUniCommonBaseRepository common) : base(common)
        {
        }

        #region instance-reg
        public async Task<CommonDataPage> GetImportPageAsync(FilterBase flt, string import_type)
        {
            const string storedProcedure = "sp_res_import_page";
            return await GetDataListPageAsync(storedProcedure, flt, new { import_type });
        }
        public async Task<BaseValidate> DelImport(Guid impId)
        {
            const string storedProcedure = "sp_res_import_del";
            return await DeleteAsync(storedProcedure, new { impId });
        }
        #endregion instance-reg

    }
}

