using System.Collections.Generic;
using UNI.Model;
using UNI.Model.APPM;

namespace UNI.Resident.Model
{

    public class CustomerShort
    {
        public string CustId { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string AvatarUrl { get; set; }
        public CustomerShort()
        {

        }
        public CustomerShort(string phone, string email, string fullName)
        {
            this.Phone = phone;
            this.Email = email;
            this.FullName = fullName;
        }
    }
    public class CustomerInfoSet : CustomerShort
    {
        private const string con_CustomerName = "Customer Name";
        public int IsSex { get; set; }
        public string Birthday { get; set; }
        public string PassNo { get; set; }
        public string PassDate { get; set; }
        public string PassPlace { get; set; }
        public string Address { get; set; }
        public string ProvinceCd { get; set; }
        public bool IsForeign { get; set; }
        public string CountryCd { get; set; }

        //public List<crmCategory> Categories { get; set; }
        //public string ValidateCustomer()
        //{
        //    string strerror = StringHelper.CheckNull(this.FullName, con_CustomerName);
        //    if (strerror != null)
        //        return strerror;
        //    strerror = StringHelper.CheckPhoneNo(this.Phone);
        //    if (strerror != null)
        //        return strerror;
        //    strerror = StringHelper.CheckEmail(this.Email);
        //    if (strerror != null)
        //        return strerror;
        //    if (!this.IsForeign)
        //        strerror = StringHelper.CheckPassNo(this.PassNo);
        //    if (strerror != null)
        //        return strerror;
        //    strerror = StringHelper.CheckDate(this.PassDate);
        //    if (strerror != null)
        //        return strerror;
        //    strerror = StringHelper.CheckDate(this.Birthday);
        //    if (strerror != null)
        //        return strerror;
        //    return null;
        //}
        public CustomerInfoSet()
        {

        }
        public CustomerInfoSet(CustomerShort baseCus)
        {
            CustId = baseCus.CustId;
            FullName = baseCus.FullName;
            Phone = baseCus.Phone;
            AvatarUrl = baseCus.AvatarUrl;
        }
        public CustomerShort Short()
        {
            return new CustomerShort
            {
                CustId = this.CustId,
                Phone = this.Phone,
                Email = this.Email,
                FullName = this.FullName,
                AvatarUrl = this.AvatarUrl
            };
        }
    }
    public class CustomerProfile: CustomerInfoSet
    {
        public string CifNo { get; set; }
    }
    public class CustomerInfoGet : CustomerProfile
    {
        public string SexName { get; set; }
        public bool IsContact { get; set; }
        public bool IsEmployee { get; set; }
        public string ProvinceName { get; set; }
        public string GroupName { get; set; }
        public string CardCd { get; set; }
        public string GroupIds { get; set; }
        public string categoryNames { get; set; }
        //public List<RoomFile> Rooms { get; set; }
    }
    public class CustPoint
    {
        public string PointCd { get; set; }
        public int CurrentPoint { get; set; }
        public string LastDate { get; set; }
        public string Priority { get; set; }
    }
    //public class UserLock
    //{
    //    public string userId { get; set; }
    //}
    public class UserAdmin
    {
        public string userId { get; set; }
        public bool isAdmin { get; set; }
    }
    public class FilterBaseCustomer : FilterBase
    {
        public string category { get; set; }
        public int groupsId { get; set; }
        public int statusId { get; set; }
        public int base_type { get; set; }

        public FilterBaseCustomer(string clientid, string userid, int? offset, int? pagesize, string category, string filter, 
            int groupid, int statusid, int base_type) : base(clientid, userid, offset, pagesize, filter,0)
        {
            this.category = category;
            this.groupsId = groupid;
            this.statusId = statusid;
            this.base_type = base_type;
        }
    }
    public class FilterBaseCustIssue : FilterBase
    {
        public string ProjectCd { get; set; }
        public int Status { get; set; }
        public string CustId { get; set; }
        //public int IsUser { get; set; }

        public FilterBaseCustIssue(string clientid, string userid, int? offset, int? pagesize, string projects, string filter,
            int status, string custId) : base(clientid, userid, offset, pagesize, filter,0)
        {
            this.ProjectCd = projects;
            this.Status = status;
            this.CustId = custId;
            //this.IsUser = isuser;
        }
    }
    public class CustomerFilter : FilterBase
    {
        public int base_Type { get; set; }
        public int GroupId { get; set; }
        public string category { get; set; }
        public int status { get; set; }
        public string StartDate { get; set; }
        public string EndDate { get; set; }
        public int Foreign { get; set; }
        public int Sex { get; set; }
        public CustomerFilter(string clientid, string userid, int? offset, int? pagesize, string filter, int gridWidth,
            int base_type,  string category, int groupId, int status, string startdate, string enddate, int foreign, int sex) 
            : base(clientid, userid, offset, pagesize, filter, gridWidth)
        {
            this.base_Type = base_type;
            this.GroupId = groupId;
            this.category = category;
            this.status = status;
            this.StartDate = startdate;
            this.EndDate = enddate;
            this.Foreign = foreign;
            this.Sex = sex;
        }
    }
    public class CustomerMembership
    {
        public string CustId { get; set; }
        public string GroupIds { get; set; }
        public bool IsLeaveOldGroup { get; set; }
        public CustomerMembership(string custId, string groupIds, bool isLeaveOldGroup)
        {
            this.CustId = custId;
            this.GroupIds = groupIds;
            this.IsLeaveOldGroup = isLeaveOldGroup;
        }
    }
    public class CrmCustomer : CustomerInfoSet
    {
        public string GroupIds { get; set; }
    }
    //public class CrmCustomerMail: EmailBase
    //{
    //    public int foreign { get; set; }
    //    public int sex { get; set; }
    //    public List<crmCategory> Categories { get; set; }
    //    public List<crmGroup> Groups { get; set; }
    //    public List<CustomerShort> CustomerShorts { get; set; }
    //    public List<string> Emails { get; set; }
    //    public bool send_series { get; set; }
    //}
    //public class GroupMail : EmailBase
    //{
    //    public List<crmGroup> Groups { get; set; }
    //}
    public class CrmCustomerMessage : MessageBase
    {
        public int foreign { get; set; }
        public int sex { get; set; }
        //public List<crmCategory> Categories { get; set; }
        //public List<crmGroup> Groups { get; set; }
        public List<CustomerShort> CustomerShorts { get; set; }
        public List<string> Phones { get; set; }
        public bool send_series { get; set; }
    }
    //public class GroupMessage : MessageBase
    //{
    //    public List<crmGroup> Groups { get; set; }
    //}
}
