using System;
using System.Collections.Generic;
using System.Text;

namespace UNI.Resident.Model
{
    public class HomMemberProfileSet
    {
        public string CustId { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string Address { get; set; }
        public int Sex { get; set; }
        public string Birthday { get; set; }
        public string FaceId { get; set; }
        public string FaceRecogUrl1 { get; set; }
        public string FaceRecogUrl2 { get; set; }
        public string FaceRecogUrl3 { get; set; }
        public string FaceRecogUrl4 { get; set; }
        public string FaceRecogUrl5 { get; set; }
        public string AvatarUrl { get; set; }
        public int RelationId { get; set; }
    }
}
