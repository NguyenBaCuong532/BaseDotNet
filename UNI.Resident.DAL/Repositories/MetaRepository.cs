using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces;
using UNI.Utils;

namespace UNI.Resident.DAL.Repositories
{
    /// <summary>
    /// Meta Repository
    /// </summary>
    /// Author: hoanpv
    /// CreatedDate: 2024-09-30
    /// <seealso cref="MetaRepository" />
    public class MetaRepository : UniBaseRepository, IMetaRepository
    {
        public MetaRepository(IUniCommonBaseRepository commonRequestInfo) : base(commonRequestInfo)
        {
        }
        //public Task<CommonViewInfo> GetMetaFilter()
        //{
        //    return base.GetTableFilterAsync(nbDataTableFilter.META_FILTER);
        //}

        public async Task<CommonDataPage> GetMetaPage(FilterBase filter, string source_type, int? meta_type, string baseUrl)
        {
            const string storedProcedure = "sp_meta_info_page";
            return await base.GetDataListPageAsync(storedProcedure, filter, new { sourceOid = filter.id, source_type = source_type, meta_type = meta_type, baseUrl = baseUrl });
        }
        public async Task<CommonViewOidInfo> GetMetaInfo(Guid? oid, Guid? parentOid, string source_type)
        {
            const string storedProcedure = "sp_meta_info_fields";
            return await base.GetFieldsAsync<CommonViewOidInfo>(storedProcedure, new { oid, sourceOid = parentOid, source_type });
        }
        public async Task<BaseValidate> SetMetaInfo(CommonViewOidInfo info)
        {
            //const string storedProcedure = "sp_dic_table_set";
            //return base.SetAsync<BaseValidate>(storedProcedure, param =>
            //{
            //    param.Add("@Oid", info.Oid);
            //    param.Add("@tableName", info.tableKey);
            //    param.AddTable("@fields", "dataFieldType", info.group_fields.SelectMany(f => f.fields).Select(y => new DicField { field_name = y.field_name, data_type = y.data_type, columnValue = y.columnValue ?? "" }).ToList());
            //    return param;
            //});
            const string storedProcedure = "sp_meta_info_set";
            return await base.SetInfoAsync<BaseValidate>(storedProcedure, info, new { Oid = info.Oid });
        }
        public async Task<BaseValidate> DelMetaInfo(string Oids)
        {
            const string storedProcedure = "sp_meta_info_del";
            return await base.DeleteAsync(storedProcedure, new { Oids = Oids });
        }
        //public async Task<List<nbMediaItem>> GetMetaTrees(string source_type, Guid? parentOid, string filter)
        //{
        //    const string storedProcedure = "sp_meta_info_tree";
        //    var result = await base.GetListAsync<nbMediaItem>(storedProcedure, new { source_type = source_type, filter = filter, parentOid = parentOid });
        //    return result.ToList();
        //}
        //public Task<List<nbMediaItemTree>> GetMetaTreeNode(string source_type, Guid? parentOid, string filter)
        //{
        //    const string storedProcedure = "sp_meta_info_node";
        //    var param = new DynamicParameters();
        //    param.Add("@filter", filter);
        //    param.Add("@parentOid", parentOid);
        //    param.Add("@source_type", source_type, DbType.String, ParameterDirection.InputOutput);
        //    var rs = base.GetMultipleAsync(storedProcedure, param, result =>
        //    {
        //        var data = result.Read<nbMediaItemTree>().ToList();
        //        data.ForEach(i => i.children = data.Where(ch => ch.parent_type == i.key).ToList());
        //        return Task.FromResult(data.Where(i => i.parent_type == null).ToList());
        //    });
        //    return rs;
        //}
        public async Task<BaseValidate> SetMetaUpload(MediaFile info, UploadResponse upload)
        {
            const string storedProcedure = "sp_meta_info_set";
            var field = new CommonViewOidInfo { group_fields = info.group_fields?.FromJson<List<viewGroup>>() };
            if (field.group_fields == null) { field.group_fields = new List<viewGroup>(); }
            return await base.GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, field.ToObject(),
                param =>
                {
                    param.Add("@Oid", info.Oid);
                    param.Add("@sourceOid", info.parentOid);
                    param.Add("@source_type", info.source_type);
                    param.Add("@file_name", info.formFile.FileName);
                    param.Add("@file_url", upload.FilePath);
                    param.Add("@objectName", upload.ObjectName);
                    param.Add("@bucket", upload.Bucket);
                    param.Add("@file_size", info.formFile.Length);
                    param.Add("@file_type", Path.GetExtension(info.formFile.FileName));
                    return param;
                });
        }
        public async Task<List<CommonValue>> GetFileList(string source_type, int meta_type, Guid sourceOid)
        {
            var storedProcedure = "sp_meta_info_list";
            var result = await base.GetListAsync<CommonValue>(storedProcedure, new { source_type = source_type, meta_type = meta_type, sourceOid = sourceOid });
            return result.ToList();
        }
        public async Task<List<FileStorageInfo>> GetMetaDetail(Guid? oid, Guid? parentOid)
        {
            const string storedProcedure = "sp_meta_info_get";
            var result = await base.GetListAsync<FileStorageInfo>(storedProcedure, new { oid, parentOid });
            return result.ToList();
        }
    }
}