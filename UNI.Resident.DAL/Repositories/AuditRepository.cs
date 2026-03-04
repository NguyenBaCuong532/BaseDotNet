using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using UNI.Model;
using UNI.Model.Audit;
using UNI.Resident.DAL.Interfaces;

namespace UNI.Resident.DAL.Repositories
{
    public class AuditRepository : IAuditRepository
    {
        private readonly ILogger<AuditRepository> _logger;
        private readonly string _connectionString;
        public AuditRepository(ILogger<AuditRepository> logger, IConfiguration configuration)
        {
            _logger = logger;
            _connectionString = configuration.GetConnectionString("AuditManagerConnection");
        }

        public void InsertAuditLogs(AuditModel objauditmodel)
        {
            const string storedProcedure = "Usp_InsertAuditLogs";

            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@ApiName", objauditmodel.ApiName);
                    param.Add("@ControllerName", objauditmodel.ControllerName);
                    param.Add("@ActionName", objauditmodel.ActionName);
                    param.Add("@IPAddress", objauditmodel.IpAddress);
                    param.Add("@SessionID", objauditmodel.SessionId);
                    param.Add("@PageAccessed", objauditmodel.PageAccessed);
                    param.Add("@UserID", objauditmodel.UserId);
                    param.Add("@UrlReferrer", objauditmodel.UrlReferrer);
                    param.Add("@ClientId", objauditmodel.ClientId);
                    connection.Execute(storedProcedure, param, null, commandType: CommandType.StoredProcedure);

                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void InsertAuditAppLogs(AuditModelApp objauditmodel)
        {
            const string storedProcedure = "Usp_InsertAuditAppLogs";

            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@ApiName", objauditmodel.ApiName);
                    param.Add("@Method", objauditmodel.Method);
                    param.Add("@ControllerName", objauditmodel.ControllerName);
                    param.Add("@ActionName", objauditmodel.ActionName);
                    param.Add("@IPAddress", objauditmodel.IpAddress);
                    param.Add("@SessionID", objauditmodel.SessionId);
                    param.Add("@PageAccessed", objauditmodel.PageAccessed);
                    param.Add("@UserID", objauditmodel.UserId);
                    param.Add("@Data", objauditmodel.Data);
                    param.Add("@UrlReferrer", objauditmodel.UrlReferrer);
                    param.Add("@Description", objauditmodel.Description);
                    param.Add("@ClientId", objauditmodel.ClientId);
                    connection.Execute(storedProcedure, param, null, commandType: CommandType.StoredProcedure);

                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public void InsertAuditServiceLogs(AuditModelApp objauditmodel)
        {
            const string storedProcedure = "Usp_InsertAuditServiceLogs";

            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@ApiName", objauditmodel.ApiName);
                    param.Add("@Method", objauditmodel.Method);
                    param.Add("@ControllerName", objauditmodel.ControllerName);
                    param.Add("@ActionName", objauditmodel.ActionName);
                    param.Add("@IPAddress", objauditmodel.IpAddress);
                    param.Add("@SessionID", objauditmodel.SessionId);
                    param.Add("@PageAccessed", objauditmodel.PageAccessed);
                    param.Add("@UserID", objauditmodel.UserId);
                    param.Add("@Data", objauditmodel.Data);
                    param.Add("@UrlReferrer", objauditmodel.UrlReferrer);
                    param.Add("@Description", objauditmodel.Description);
                    param.Add("@ClientId", objauditmodel.ClientId);
                    connection.Execute(storedProcedure, param, null, commandType: CommandType.StoredProcedure);

                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public AuditPage GetAuditPage(AuditFilter filter)
        {
            const string storedProcedure = "sp_audit_page";
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    var param = new DynamicParameters();
                    param.Add("@userId", filter.userId);
                    param.Add("@filter", filter.filter);
                    param.Add("@gridWidth", filter.gridWidth);
                    param.Add("@Offset", filter.offSet);
                    param.Add("@PageSize", filter.pageSize);
                    param.Add("@StartDt", filter.pageSize);
                    param.Add("@EndDt", filter.pageSize);
                    param.Add("@ControllerName", filter.ControllerName);
                    param.Add("@ApiName", filter.ApiName);
                    param.Add("@Total", 0, DbType.Int32, ParameterDirection.InputOutput);
                    param.Add("@TotalFiltered", 0, DbType.Int32, ParameterDirection.InputOutput);

                    var result = connection.QueryMultiple(storedProcedure, param, commandType: CommandType.StoredProcedure);
                    var data = new AuditPage();
                    if (filter.offSet == null || filter.offSet == 0)
                    {
                        data.gridflexs = result.Read<viewGridFlex>().ToList();
                    }
                    var lst = result.Read<AuditModelApp>().ToList();
                    data.dataList = new ResponseList<List<AuditModelApp>>(lst, param.Get<int>("@Total"), param.Get<int>("@TotalFiltered"));
                    return data;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

    }
}
