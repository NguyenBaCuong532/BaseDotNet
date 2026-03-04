using NSwag.Annotations;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Globalization;
using UNI.Model;
using UNI.Utils;

namespace UNI.Resident.Model
{
    public class ReportFilter : FilterInput
    {
        [OpenApiIgnore]
        public string UserId { get; set; }
        public ReportType? exportType { get; set; } 
        public string tempType { get; set; }
        public bool IsDataTable { get; set; } = false;
    }

    public static class ReportFilterExtension
    {
        public static string GetFileExtension(this ReportFilter report)
        {
            if (report.exportType == null) return ".xlsx";
            switch (report.exportType)
            {
                case ReportType.pdf:
                    return ".pdf";
                case ReportType.xlsx:
                    return ".xlsx";
                case ReportType.docx:
                    return ".docx";
                default:
                    return ".pdf";
            }
        }
    }

    //public class ReportDateRangeFilter1 : ReportFilter
    //{
    //    public string FromDate { get; set; }
    //    public string ToDate { get; set; }
    //    public string Oids { get; set; }
    //    public string Department { get; set; }
    //    public string id { get; set; }
    //}

    public class ReportDateRangeFilter : ReportFilter
    {
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public string Oids { get; set; }
        public string Department { get; set; }
        public string SurveyOid { get; set; }
    }

    public class ReportCommonFilter : ReportDateRangeFilter
    {
        public int? Month { get; set; }
        public int? Year { get; set; }
        public int? Quarter { get; set; }
        public string Date { get; set; }
        public string Parameter { get; set; }
        public bool? empStatus { get; set; }
        public int? FromDayOfLastMonth { get; set; }
        public int? PayrollPeriod { get; set; }
        public string MonthYear { get; set; }
        public string HalfYear { get; set; }

        public DateTime GetFromDate()
        {

            DateTime _FromDate = DateTime.MinValue;
            if (!string.IsNullOrEmpty(this.Date) || !string.IsNullOrEmpty(this.FromDate) || !string.IsNullOrEmpty(this.MonthYear) || this.Year.HasValue || this.Month.HasValue || this.Quarter.HasValue)
            {

                if (!string.IsNullOrEmpty(this.Date))
                {
                    _FromDate = DateTime.Parse(this.Date, new CultureInfo("vi-VN"));
                }
                if (!string.IsNullOrEmpty(this.FromDate))
                {
                    _FromDate = DateTime.Parse(this.FromDate, new CultureInfo("vi-VN"));
                }
                if (!string.IsNullOrEmpty(this.MonthYear))
                {
                    _FromDate = DateTime.Parse(this.MonthYear, new CultureInfo("vi-VN"));
                }
                if (this.Year.HasValue && this.Month.HasValue)
                {
                    _FromDate = new DateTime(this.Year.Value, this.Month.Value, 1);
                    if (PayrollPeriod == 1)
                        _FromDate = _FromDate.AddMonths(-1).AddDays(this.FromDayOfLastMonth.Value - 1);
                }
                if (this.Year.HasValue && !this.Month.HasValue)
                {
                    _FromDate = new DateTime(this.Year.Value, 1, 1);
                    if (PayrollPeriod == 1)
                        _FromDate = _FromDate.AddMonths(-1).AddDays(this.FromDayOfLastMonth.Value - 1);
                }
                if (this.Year.HasValue && this.Quarter.HasValue)
                {
                    _FromDate = new DateTime(this.Year.Value, this.Quarter.Value * 3 - 2, 1);
                    if (this.PayrollPeriod == 1)
                        _FromDate = _FromDate.AddMonths(-1).AddDays(this.FromDayOfLastMonth.Value - 1);
                }
                if (this.Year.HasValue && !this.Month.HasValue && !this.Quarter.HasValue)
                {
                    _FromDate = new DateTime(this.Year.Value, 1, 1);
                    if (this.PayrollPeriod == 1)
                        _FromDate = _FromDate.AddMonths(-1).AddDays(this.FromDayOfLastMonth.Value - 1);
                }
                if (!string.IsNullOrEmpty(this.MonthYear))
                {
                    if (PayrollPeriod == 1)
                        _FromDate = _FromDate.AddMonths(-1).AddDays(this.FromDayOfLastMonth.Value - 1);
                }
            }
            else
            {
                _FromDate = new DateTime(this.Year ?? DateTime.Now.Year, 1, 1);
            }


            if (HalfYear == "CN")
                _FromDate = new DateTime(this.Year ?? DateTime.Now.Year, 7, 1);

            return _FromDate;
        }
        public DateTime GetToDate()
        {
            DateTime _ToDate = DateTime.MinValue;
            if (!string.IsNullOrEmpty(this.Date) || !string.IsNullOrEmpty(this.ToDate) || !string.IsNullOrEmpty(this.MonthYear) || this.Year.HasValue || this.Month.HasValue || this.Quarter.HasValue)
            {
                if (!string.IsNullOrEmpty(this.Date))
                {
                    _ToDate = DateTime.Parse(this.Date, new CultureInfo("vi-VN"));
                }
                if (!string.IsNullOrEmpty(this.ToDate))
                {
                    _ToDate = DateTime.Parse(this.ToDate, new CultureInfo("vi-VN"));
                }
                if (!string.IsNullOrEmpty(this.MonthYear))
                {
                    _ToDate = DateTime.Parse(this.MonthYear, new CultureInfo("vi-VN"));
                }
                if (this.Year.HasValue && this.Month.HasValue)
                {
                    _ToDate = GetFromDate().AddMonths(1).AddDays(-1);
                }
                if (this.Year.HasValue && !this.Month.HasValue)
                {
                    _ToDate = GetFromDate().AddMonths(12).AddDays(-1);
                }
                if (this.Year.HasValue && this.Quarter.HasValue)
                {
                    _ToDate = GetFromDate().AddMonths(3).AddDays(-1);
                }
                if (this.Year.HasValue && !this.Month.HasValue && !this.Quarter.HasValue)
                {
                    _ToDate = GetFromDate().AddMonths(12).AddDays(-1);
                }
                if (!string.IsNullOrEmpty(this.MonthYear))
                {
                    _ToDate = GetFromDate().AddMonths(1).AddDays(-1);
                }
            }
            else
            {
                _ToDate = GetFromDate().AddMonths(12).AddDays(-1);
            }
            if (HalfYear == "DN")
                _ToDate = GetFromDate().AddMonths(7).AddDays(-1);

            return new DateTime(_ToDate.Year, _ToDate.Month, _ToDate.Day, 23, 59, 59);
        }
      
        public string ToReportTime()
        {
            switch (Parameter)
            {
                case "BYDATE":
                    return $"Ngày {Date ?? ""}";
                case "FDTD":
                    return $"Từ {FromDate} đến {ToDate}";
                case "MONTH":
                    return $"Tháng {Month} năm {Year}";
                case "QUARTER":
                    return $"Quý {Quarter} năm {Year}";
                case "YEAR":
                    return $"Năm {Year}";
                default:
                    return string.Empty;
            }
        }
        public ICollection<SqlParameter> ToParameters()
        {
            return new List<SqlParameter>
            {
                new SqlParameter("UserId", SqlDbType.NVarChar) { Value = UserId },
                new SqlParameter("OffSet", SqlDbType.Int) { Value = offSet },
                new SqlParameter("PageSize", SqlDbType.Int) { Value = pageSize },
                new SqlParameter("StrFromDate", SqlDbType.VarChar) { Value = GetFromDate().ToString("dd/MM/yyyy") },
                new SqlParameter("StrToDate", SqlDbType.VarChar) { Value = GetToDate().ToString("dd/MM/yyyy") },
                new SqlParameter("EmployeeOids", SqlDbType.NVarChar) { Value = Oids }
            };
        }
    }

    //Tổng hợp công nợ phải thu, phải trả
    public class ReportReceivablePayable : ReportCommonFilter
    {
        public string ProjectCd { get; set; }
        public string BuildingCd { get; set; }
        public string RoomCode { get; set; }
        /* public string receiveId { get; set; }    */
    }


    //public class ReportCommonFilter2 : ReportCommonFilter
    //{
    //    public string OidsNDD { get; set; }
    //    public string FormSurType { get; set; }
    //    public int? source_type { get; set; }
    //    public string ContractNo { get; set; }

    //}
    //public class ReportCommonFilter3 : ReportCommonFilter
    //{
    //    public int? app_st { get; set; }
    //    public int? source_type { get; set; }
    //}

    public class ReportBuildingRoomFilter : ReportCommonFilter
    {
        public string ProjectCd { get; set; }
    }





}


