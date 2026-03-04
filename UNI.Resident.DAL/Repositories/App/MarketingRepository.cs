using Dapper;
using Microsoft.Extensions.Configuration;
using SSG.Resident.DAL.Interfaces.App;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Marketing;

namespace SSG.Resident.DAL.Repositories.App
{
    /// <summary>
    /// Marketing Repository
    /// </summary>
    /// Author: taint
    /// CreatedDate: 16/11/2016 2:07 PM
    /// <seealso cref="MarketingRepository" />
    public class MarketingRepository : IMarketingRepository
    {
        private readonly string _connectionString;

        public MarketingRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("BigtecConnection");
        }
        #region App Marketing
        public mktVoucherGet GetVoucher(string userId, string vou_Id)
        {
            const string storedProcedure = "sp_MKT_Voucher_Get";
            try
            {

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@vou_Id", vou_Id);
                    var result = connection.QueryFirstOrDefault<mktVoucherGet>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public ResponseList<List<mktVoucher>> GetVoucherPage(FilterBase2 filter)
        {
            const string storedProcedure = "sp_MKT_Voucher_App_Page";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@vou_status", filter.Id);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);
                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var deplist = result.Read<mktVoucher>().ToList();
                    return new ResponseList<List<mktVoucher>>(deplist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        #endregion App Marketing

        #region Web core
        public mktVoucherInfoPage GetVoucherInfoPage(FilterBase filter)
        {
            const string storedProcedure = "sp_MKT_Voucher_Info_Page";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@gridWidth", filter.gridWidth);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);
                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = new mktVoucherInfoPage();
                    if (filter.offSet == null || filter.offSet == 0)
                    {
                        data.gridflexs = result.Read<viewGridFlex>().ToList();
                    }
                    var deplist = result.Read<mktVoucherShort>().ToList();
                    data.dataList = new ResponseList<List<mktVoucherShort>>(deplist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public mktVoucherInfo GetVoucherInfo(string userId,  long vou_id)
        {
            const string storedProcedure = "sp_MKT_Voucher_Info_Fields";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    //param.Add("@action", action);
                    param.Add("@vou_id", vou_id);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = result.ReadFirstOrDefault<mktVoucherInfo>();
                    if (data != null)
                    {
                        data.group_fields = result.Read<viewGroup>().ToList();
                        if (data.group_fields != null && data.group_fields.Count > 0)
                        {
                            var flds = result.Read<viewField>().ToList();
                            foreach (var gr in data.group_fields)
                            {
                                gr.fields = flds.Where(f => f.group_cd == gr.group_cd).ToList();
                            }
                        }
                    }
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        
        public async Task SetVoucherInfo(string userId, mktVoucherInfo voucher)
        {
            const string storedProcedure = "sp_MKT_Voucher_Info_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@vou_id", voucher.vou_id);
                    param.Add("@group_cd", voucher.GetValueByFieldName("group_cd"));
                    param.Add("@vou_title", voucher.GetValueByFieldName("vou_title"));
                    param.Add("@vou_intro", voucher.GetValueByFieldName("vou_intro"));
                    param.Add("@vou_unit_point", voucher.GetValueByFieldName("vou_unit_point"));
                    param.Add("@vou_exch_point", voucher.GetValueByFieldName("vou_exch_point"));
                    param.Add("@vou_exch_amt", voucher.GetValueByFieldName("vou_exch_amt"));
                    param.Add("@vou_guid", voucher.GetValueByFieldName("vou_guid"));
                    param.Add("@vou_app_to", voucher.GetValueByFieldName("vou_app_to"));
                    param.Add("@vou_app_local", voucher.GetValueByFieldName("vou_app_local"));
                    param.Add("@vou_cover_url", voucher.GetValueByFieldName("vou_cover_url"));
                    param.Add("@vou_st", voucher.GetValueByFieldName("vou_st"));

                    var schm = await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    return;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<mktVoucherShort> GetVoucherInfoList(string userId, string filter)
        {
            const string storedProcedure = "sp_MKT_Voucher_Info_List";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@filter", filter);
                    var result = connection.Query<mktVoucherShort>(storedProcedure, param, commandType: CommandType.StoredProcedure).ToList();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public mktVoucherOpenPage GetVoucherOpenPage(FilterBase1 filter)
        {
            const string storedProcedure = "sp_MKT_Voucher_Open_Page";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@gridWidth", filter.gridWidth);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);
                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = new mktVoucherOpenPage();
                    if (filter.offSet == null || filter.offSet == 0)
                    {
                        data.gridflexs = result.Read<viewGridFlex>().ToList();
                    }
                    var deplist = result.Read<mktVoucherOpen>().ToList();
                    data.dataList = new ResponseList<List<mktVoucherOpen>>(deplist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public mktVoucherOpenInfo GetVoucherOpen(string userId,  long vou_open_id, long vou_id, string provider_cd)
        {
            const string storedProcedure = "sp_MKT_Voucher_Open_Fields";
            try
            {

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    //param.Add("@action", action);
                    param.Add("@vou_open_id", vou_open_id);
                    param.Add("@vou_open_id", vou_open_id);
                    param.Add("@vou_id", vou_id);
                    param.Add("@provider_cd", provider_cd);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = result.ReadFirstOrDefault<mktVoucherOpenInfo>();
                    if (data != null)
                    {
                        data.group_fields = result.Read<viewGroup>().ToList();
                        if (data.group_fields != null && data.group_fields.Count > 0)
                        {
                            var flds = result.Read<viewField>().ToList();
                            foreach (var gr in data.group_fields)
                            {
                                gr.fields = flds.Where(f => f.group_cd == gr.group_cd).ToList();
                            }
                        }
                    }
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<BaseValidate> SetVoucherOpen(string userId, mktVoucherOpenInfo vouOpen)
        {
            const string storedProcedure = "sp_MKT_Voucher_Open_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@vou_open_id", vouOpen.vou_open_id);
                    param.Add("@vou_id", vouOpen.GetValueByFieldName("vou_id"));
                    param.Add("@provider_cd", vouOpen.GetValueByFieldName("provider_cd"));
                    param.Add("@provider_name", vouOpen.GetValueByFieldName("provider_name"));
                    param.Add("@vou_open_qty", vouOpen.GetValueByFieldName("vou_open_qty"));
                    param.Add("@vou_open_point", vouOpen.GetValueByFieldName("vou_open_point"));
                    param.Add("@vou_open_amt", vouOpen.GetValueByFieldName("vou_open_amt"));
                    param.Add("@vou_exch_start_at", vouOpen.GetValueByFieldName("vou_exch_start_at"));
                    param.Add("@vou_exch_end_at", vouOpen.GetValueByFieldName("vou_exch_end_at"));
                    param.Add("@vou_expire_at", vouOpen.GetValueByFieldName("vou_expire_at"));
                    param.Add("@vou_open_st", vouOpen.GetValueByFieldName("vou_open_st"));

                    return await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public mktVoucherTranPage GetVoucherTranPage(FilterBase1 filter)
        {
            const string storedProcedure = "sp__Page";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@Filter", filter.filter);
                    param.Add("@gridWidth", filter.gridWidth);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);
                    param.Add("@Total", 0, DbType.Int64, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int64, ParameterDirection.InputOutput);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = new mktVoucherTranPage();
                    if (filter.offSet == null || filter.offSet == 0)
                    {
                        data.gridflexs = result.Read<viewGridFlex>().ToList();
                    }
                    var deplist = result.Read<mktVoucherTran>().ToList();
                    data.dataList = new ResponseList<List<mktVoucherTran>>(deplist, param.Get<long>("@Total"), param.Get<long>("@TotalFiltered"));
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public mktVoucherTranInfo GetVoucherTran(string userId, long vou_tnx_id)
        {
            const string storedProcedure = "sp_MKT_Voucher_Tran_Fields";
            try
            {

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@Id", vou_tnx_id);
                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = result.ReadFirstOrDefault<mktVoucherTranInfo>();
                    if (data != null)
                    {
                        data.group_fields = result.Read<viewGroup>().ToList();
                        if (data.group_fields != null && data.group_fields.Count > 0)
                        {
                            var flds = result.Read<viewField>().ToList();
                            foreach (var gr in data.group_fields)
                            {
                                gr.fields = flds.Where(f => f.group_cd == gr.group_cd).ToList();
                            }
                        }
                    }
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<BaseValidate> SetVoucherTran(string userId, mktVoucherTranInfo vouTran)
        {
            const string storedProcedure = "sp_MKT_Voucher_Tran_Set";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", userId);
                    param.Add("@vou_id", vouTran.vou_tnx_id);
                    param.Add("@scheme_cd", vouTran.GetValueByFieldName("scheme_cd"));
                    param.Add("@scheme_desc", vouTran.GetValueByFieldName("scheme_desc"));
                    param.Add("@inv_tenor", vouTran.GetValueByFieldName("inv_tenor"));
                    param.Add("@inv_min_amt", vouTran.GetValueByFieldName("inv_min_amt"));
                    param.Add("@int_base_rt", vouTran.GetValueByFieldName("int_base_rt"));
                    param.Add("@int_buyback_rt", vouTran.GetValueByFieldName("int_buyback_rt"));
                    param.Add("@sale_discount_rt", vouTran.GetValueByFieldName("sale_discount_rt"));
                    param.Add("@trad_after_month", vouTran.GetValueByFieldName("trad_after_month"));
                    param.Add("@adv_after_month", vouTran.GetValueByFieldName("adv_after_month"));
                    param.Add("@adv_terminal_day", vouTran.GetValueByFieldName("adv_terminal_day"));
                    param.Add("@adv_max_rt", vouTran.GetValueByFieldName("adv_max_rt"));
                    param.Add("@adv_fee_indue_rt", vouTran.GetValueByFieldName("adv_fee_indue_rt"));
                    param.Add("@adv_fee_indue_day", vouTran.GetValueByFieldName("adv_fee_indue_day"));

                    return await connection.QueryFirstAsync<BaseValidate>(storedProcedure, param, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion Web core

    }
}
