using Microsoft.AspNetCore.Hosting;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Invoice;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model;
using UNI.Resident.Model.Receipt;
using UNI.Utils;

namespace UNI.Resident.DAL.Repositories.Invoice
{
    public class ReceiptRepository : UniBaseRepository, IReceiptRepository
    {
        private readonly ILogger<ReceiptRepository> _logger;
        private readonly INotifyRepository _appRepository;
        private readonly IHostingEnvironment _environment;
        private readonly FlexcellUtils flexcellUtils;

        public ReceiptRepository(IUniCommonBaseRepository common,
            ILogger<ReceiptRepository> logger,
            IFirebaseRepository notifyRepository,
            INotifyRepository appRepository,
            IHostingEnvironment environment) : base(common)
        {
            _logger = logger;
            _appRepository = appRepository;
            _environment = environment;
            flexcellUtils = new FlexcellUtils();
        }
        #region web-rec

        public CommonViewInfo GetReceiptFilter(string userId)
        {
            const string storedProcedure = "sp_res_receipt_filter";
            return GetFieldsAsync<CommonViewInfo>(storedProcedure, new { userId }).Result;
        }
        public async Task<CommonDataPage> GetReceiptPagev2(ReceiptRequestModel filter)
        {
            const string storedProcedure = "sp_res_receipt_page";
            return await GetDataListPageAsync(storedProcedure,
                filter,
                new
                {
                    filter.ProjectCd,
                    filter.isExpected,
                    filter.isResident,
                    filter.isDateFilter,
                    filter.FromDate,
                    filter.ToDate,
                    filter.gridWidth,
                    periods_oid = filter.PeriodsOid
                });
        }

        public async Task<ReceiptInfo> GetReceiptInfo(string ReceiptId)
        {
            const string storedProcedure = "sp_res_receipt_field";
            return await GetFieldsAsync<ReceiptInfo>(storedProcedure, new { ReceiptId });
        }

        public async Task<BaseValidate> SetReceiptInfo(BaseCtrlClient client, ReceiptInfo info)
        {
            const string storedProcedure = "sp_res_receipt_SetInfo";
            return await GetMultipleAsync<BaseValidate>(storedProcedure, param =>
            {
                param.Add("UserID", client.UserId);
                param.Add("ReceiptId", info.Id);
                param.Add("ProjectCd", info.GetValueByFieldName("ProjectCd"));
                param.Add("ReceiptNo", info.GetValueByFieldName("ReceiptNo"));
                param.Add("ReceiptDate", info.GetValueByFieldName("ReceiptDate"));
                param.Add("ReceiveId", info.GetValueByFieldName("ReceiveId"));
                param.Add("CustId", info.GetValueByFieldName("CustId"));
                param.Add("ApartmentId", info.GetValueByFieldName("ApartmentId"));
                param.Add("TranferCd", info.GetValueByFieldName("TranferCd"));
                param.Add("Object", info.GetValueByFieldName("Object"));
                param.Add("PassNo", info.GetValueByFieldName("PassNo"));
                param.Add("PassDate", info.GetValueByFieldName("PassDate"));
                param.Add("PassPlc", info.GetValueByFieldName("PassPlc"));
                param.Add("Address", info.GetValueByFieldName("Address"));
                param.Add("Contents", info.GetValueByFieldName("Contents"));
                param.Add("Amount", info.GetValueByFieldName("Amount"));
                param.Add("Attach", info.GetValueByFieldName("Attach"));
                param.Add("IsDBCR", 1);
                param.Add("IsDebit", info.GetValueByFieldName("IsDebit"));
                param.Add("AmtSubtractPoint", info.GetValueByFieldName("AmtSubtractPoint"));
                param.Add("PaymentOption", info.GetValueByFieldName("PaymentOption"));
                return param;
            }, async result =>
            {
                var valid = await result.ReadFirstOrDefaultAsync<BaseValidate>();
                if (valid != null && valid.valid && valid.notiQue)
                {
                    var notiTake = await result.ReadFirstOrDefaultAsync<AppNotifyTake>();
                    if (notiTake != null)
                    {
                        notiTake.appUsers = (await result.ReadAsync<PushNotifyUser>()).ToList();
                        await _appRepository.TakeNotification(notiTake);
                    }
                }
                return valid;
            });
        }

        public async Task<BaseValidate> DeleteReceiptInfo(int ReceiptId)
        {
            const string storedProcedure = "sp_res_receipt_DelInfo";
            return await DeleteAsync(storedProcedure, new { ReceiptId });
        }

        public Task<string> GetBillReceiptAsync(long receiptId)
        {
            throw new System.NotImplementedException();
        }

        public async Task<ggDriverFileStream> GetServiceReceivableStreamAsync(long receiptId, ReportType reportType)
        {
            const string storedProcedure = "sp_res_receipt_bill_get";
            try
            {
                string pathFile = _environment.ContentRootPath + "\\" + FolderServiceReport.FOLDER_TEMPLATE + "\\" + HomServiceReport.RECEIVE_MONEY_TEMPLATE;
                var p = new Dictionary<string, object>();
                System.Data.DataSet ds = new System.Data.DataSet();
                using (var connection = new SqlConnection(CommonInfo.ConnectionString))
                {
                    await connection.OpenAsync();
                    var cmd = new SqlCommand(storedProcedure, connection);
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.CommandTimeout = 200;
                    //cmd.Parameters.Add("@userId", System.Data.SqlDbType.NVarChar).Value = userId;
                    cmd.Parameters.Add("@receiptId", System.Data.SqlDbType.BigInt).Value = receiptId;
                    var da = new SqlDataAdapter(cmd);
                    da.Fill(ds);
                }
                p.Add("StrDate", string.Concat(" Ngày ", System.DateTime.Now.Day.ToString(), " tháng ", System.DateTime.Now.Month.ToString(), " năm ", System.DateTime.Now.Year.ToString()));
                ggDriverFileStream serviceStream = new ggDriverFileStream();
                if (ds.Tables[0].Rows.Count != 0)
                {
                    p.Add("MoneyAmt", decimal.Parse(ds.Tables[0].Rows[0]["Amount"].ToString()).Equals(0) ? "0" : double.Parse(ds.Tables[0].Rows[0]["Amount"].ToString()).ToString("#,###", CultureInfo.GetCultureInfo("vi-VN")));
                    p.Add("MoneyByString", (decimal.Parse(ds.Tables[0].Rows[0]["Amount"].ToString()).Equals(0) ? 0 : decimal.Parse(ds.Tables[0].Rows[0]["Amount"].ToString())).ConvertMoneyToText());
                    Stream streamresult = flexcellUtils.CreateReport(pathFile, reportType, ds, p);
                    if (streamresult != null)
                    {
                        serviceStream.stream = streamresult;
                        serviceStream.fileName = System.DBNull.Value.Equals(ds.Tables[0].Rows[0]["RoomCode"].ToString()) ? System.Guid.NewGuid().ToString() : string.Concat("[" + ds.Tables[0].Rows[0]["RoomCode"].ToString(), "#", System.DateTime.Now.Day.ToString(), System.DateTime.Now.Month.ToString(), System.DateTime.Now.Year.ToString() + "]");
                        serviceStream.mimeType = "application/unknown";
                        serviceStream.documentType = 2;
                        serviceStream.folderName = System.DBNull.Value.Equals(ds.Tables[0].Rows[0]["projectFolder"].ToString()) ? System.Guid.NewGuid().ToString() : ds.Tables[0].Rows[0]["projectFolder"].ToString();
                        serviceStream.dDate = System.DateTime.Now;
                    }
                }
                return serviceStream;
            }
            catch (System.Exception ex)
            {
                _logger.LogError($"{ex}");
                return null;
            }
        }

        public async Task<int> SetReceiptBillAsync(ReceiptPrinting bill)
        {
            const string storedProcedure = "sp_res_receipt_bill_set";
            return await GetFirstOrDefaultAsync<int>(storedProcedure, new { bill.ReceiptId, bill.ReceiptBillUrl, bill.ReceiptBillViewUrl });
        }

        public async Task<CommonDataPage> GetReceiptByApartmentIdPage(ReceiptHistoryByApartmentIdModel flt)
        {
            const string storedProcedure = "sp_res_service_receipt_byapartid";
            return await GetDataListPageAsync(storedProcedure, flt, new { flt.apartmentId });
        }

        public async Task<ReceiptInfo> GetReceiptByApartmentInfo(int ApartmentId)
        {
            const string storedProcedure = "sp_res_apartment_profile_receipt_field";
            return await GetFieldsAsync<ReceiptInfo>(storedProcedure, new { ApartmentId });
        }

        public async Task<HomReceiptGet> SetReceipt(HomReceiptSet rec)
        {
            const string storedProcedure = "sp_Hom_Service_Receipt_Set";
            return await GetMultipleAsync<HomReceiptGet>(storedProcedure, param =>
            {
                param.Add("@userId", base.CommonInfo.UserId);
                param.Add("@ProjectCd", rec.ProjectCd);
                param.Add("@ReceiptId", rec.ReceiptId);
                param.Add("@ReceiptNo", rec.ReceiptNo);
                param.Add("@ReceiptDate", rec.ReceiptDate);
                param.Add("@ReceiveId", rec.ReceiveId);
                param.Add("@ApartmentId", rec.ApartmentId);
                param.Add("@CustId", rec.CustId);
                param.Add("@TranferCd", rec.TranferCd);
                param.Add("@Object", rec.Object);
                param.Add("@PassNo", rec.PassNo);
                param.Add("@PassDate", rec.PassDate);
                param.Add("@PassPlc", rec.PassPlc);
                param.Add("@Address", rec.Address);
                param.Add("@Contents", rec.Contents);
                param.Add("@Amount", rec.Amount);
                param.Add("@Attach", "");
                param.Add("@IsDBCR", 1);
                param.Add("@IsDebit", rec.IsDebit);
                param.Add("@AmtSubtractPoint", rec.SubtractPoint);
                return param;
            }, async result =>
            {
                var valid = await result.ReadFirstOrDefaultAsync<BaseValidate>();
                if (valid != null && valid.valid && valid.notiQue)
                {
                    var notiTake = await result.ReadFirstOrDefaultAsync<AppNotifyTake>();
                    if (notiTake != null)
                    {
                        notiTake.appUsers = (await result.ReadAsync<PushNotifyUser>()).ToList();
                        await _appRepository.TakeNotification(notiTake);
                    }
                }
                return result.ReadFirstOrDefault<HomReceiptGet>();
            });
        }

        public async Task<List<CommonValue>> GetPaymentAmountOptions(string receiveId)
        {
            const string storedProcedure = "sp_res_payment_option_list";
            return await GetListAsync<CommonValue>(storedProcedure, new { receiveId });
        }

        #endregion
    }
}
