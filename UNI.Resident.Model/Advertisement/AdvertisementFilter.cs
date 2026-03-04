using System;
using UNI.Model;

namespace UNI.Resident.Model.Advertisement
{
    public class AdvertisementFilter : FilterBase
    {
        public string Title { get; set; }
        public string CompanyName { get; set; }
        public bool? IsActive { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int? Position { get; set; }

        public AdvertisementFilter(string clientid, string userid, int? offset, int? pagesize, string filter, int gridWidth)
            : base(clientid, userid, offset, pagesize, filter, gridWidth)
        {
        }
    }

    public class AdvertisementAnalyticsFilter : FilterBase
    {
        public Guid? AdvertisementId { get; set; }
        public string Action { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public string DeviceType { get; set; }
        public string Platform { get; set; }

        public AdvertisementAnalyticsFilter(string clientid, string userid, int? offset, int? pagesize, string filter, int gridWidth)
            : base(clientid, userid, offset, pagesize, filter, gridWidth)
        {
        }
    }
}