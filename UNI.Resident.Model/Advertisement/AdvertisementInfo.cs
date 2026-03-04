using System;
using System.ComponentModel.DataAnnotations;
using UNI.Model;

namespace UNI.Resident.Model.Advertisement
{
    public class AdvertisementInfo : viewBaseInfo
    {
        public Guid Id { get; set; }

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

        public int ClickCount { get; set; } = 0;

        public int ViewCount { get; set; } = 0;

        public bool IsDeleted { get; set; } = false;

        // System fields
        public int AppSt { get; set; } = 0;

        [Required]
        public DateTime CreatedDt { get; set; }

        [Required]
        public Guid CreatedBy { get; set; }

        public DateTime? UpdatedDt { get; set; }

        public Guid? UpdatedBy { get; set; }
    }
}