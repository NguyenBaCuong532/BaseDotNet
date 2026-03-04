using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class HomRequestCategory
    {
        public int RequestCategoryId { get; set; }
        public string RequestCategoryName { get; set; }
    }

    public class HomRequestCategoryGet : HomRequestCategory
    {
        public List<HomRequestType> RequestTypes { get; set; }
    }
    public class HomRequestType
    {
        public int RequestTypeId { get; set; }
        public string RequestTypeName { get; set; }
        public int RequestCategoryId { get; set; }
        public bool IsFree { get; set; }
        public decimal Price { get; set; }
        public string Unit { get; set; }
        public string Note { get; set; }
        public string iconUrl { get; set; }
        public string role_id { get; set; }
        public string sub_prod_cd { get; set; }
    }
}
