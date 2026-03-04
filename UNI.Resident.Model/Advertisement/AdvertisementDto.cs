using System;
using System.ComponentModel.DataAnnotations;

namespace UNI.Resident.Model.Advertisement
{
    public class AdvertisementCreateDto
    {
        [Required]
        [MaxLength(200)]
        public string Title { get; set; }

        [MaxLength(500)]
        public string Description { get; set; }

        [Required]
        [MaxLength(500)]
        public string ImageUrl { get; set; }

        [MaxLength(500)]
        public string LinkUrl { get; set; }

        public int Position { get; set; } = 1;

        public int Priority { get; set; } = 1;

        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }

        public bool IsActive { get; set; } = true;

        [MaxLength(200)]
        public string CompanyName { get; set; }

        [MaxLength(100)]
        public string CompanyContact { get; set; }

        [MaxLength(20)]
        public string CompanyPhone { get; set; }

        [MaxLength(100)]
        public string CompanyEmail { get; set; }
    }

    public class AdvertisementUpdateDto : AdvertisementCreateDto
    {
        [Required]
        public Guid Id { get; set; }
    }

    public class AdvertisementViewDto
    {
        public Guid Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string ImageUrl { get; set; }
        public string LinkUrl { get; set; }
        public int Position { get; set; }
        public int Priority { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsActive { get; set; }
        public string CompanyName { get; set; }
        public string CompanyContact { get; set; }
        public string CompanyPhone { get; set; }
        public string CompanyEmail { get; set; }
        public int ClickCount { get; set; }
        public int ViewCount { get; set; }
        public DateTime CreatedDt { get; set; }
        public DateTime? UpdatedDt { get; set; }
    }

    public class AdvertisementTrackingDto
    {
        [Required]
        public Guid AdvertisementId { get; set; }

        [Required]
        public string Action { get; set; } // 'View', 'Click'

        public string SessionId { get; set; }
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
        public string DeviceType { get; set; }
        public string Platform { get; set; }
        public Guid? ApartmentId { get; set; }
        public Guid? BuildingId { get; set; }
    }

    public class AdvertisementStatsDto
    {
        public Guid AdvertisementId { get; set; }
        public string Title { get; set; }
        public int ViewCount { get; set; }
        public int ClickCount { get; set; }
        public double ClickThroughRate { get; set; }
        public DateTime? LastViewed { get; set; }
        public DateTime? LastClicked { get; set; }
    }
}