using System;
using System.ComponentModel.DataAnnotations;
using UNI.Model;

namespace UNI.Resident.Model.Advertisement
{
    public class AdvertisementAnalytics : viewBaseInfo
    {
        public Guid Id { get; set; }

        [Required]
        public Guid AdvertisementId { get; set; }

        public Guid? CustomerId { get; set; }

        [MaxLength(100)]
        public string SessionId { get; set; }

        [Required]
        [MaxLength(20)]
        public string Action { get; set; } // 'View', 'Click'

        [MaxLength(50)]
        public string IpAddress { get; set; }

        [MaxLength(500)]
        public string UserAgent { get; set; }

        [MaxLength(50)]
        public string DeviceType { get; set; } // 'Mobile', 'Desktop', 'Tablet'

        [MaxLength(50)]
        public string Platform { get; set; } // 'iOS', 'Android', 'Web'

        public Guid? ApartmentId { get; set; }

        public Guid? BuildingId { get; set; }

        // System fields
        public int AppSt { get; set; } = 0;

        [Required]
        public DateTime CreatedDt { get; set; }

        [Required]
        public Guid CreatedBy { get; set; }

        public DateTime? UpdatedDt { get; set; }

        public Guid? UpdatedBy { get; set; }

        // Navigation property
        public virtual AdvertisementInfo Advertisement { get; set; }
    }
}