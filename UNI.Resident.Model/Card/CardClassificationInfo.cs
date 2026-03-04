using System;
using System.Collections.Generic;
using UNI.Model;

namespace UNI.Resident.Model.Card
{
    public class CardClassificationInfo : CommonViewInfo
    {
        public ICollection<Guid> Ids { get; set; } = new List<Guid>();
    }

    public class GuidItem
    {
        public Guid Id { get; set; }
    }
}
