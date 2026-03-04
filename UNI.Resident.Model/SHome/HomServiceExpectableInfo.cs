using System;
using System.Collections.Generic;
using System.Text;
using UNI.Model;

namespace UNI.Resident.Model
{
    public class HomServiceExpectableInfo : viewBaseInfo
    {
        public List<viewGridFlex> gridflexFee;
        public List<viewGridFlex> gridflexVehicle;
        public List<viewGridFlex> gridflexLiving;
        public List<viewGridFlex> gridflexLivingDtls;
        public List<viewGridFlex> gridflexExtend;

        public List<HomPaymentApartmentFee> ServiceFee { get; set; }
        public List<HomPaymentServiceVehicle> ServiceVehicle { get; set; }
        public List<HomPaymentServiceLiving> ServiceLiving { get; set; }
        public List<HomPaymentServiceExtend> ServiceExtend { get; set; }
    }
}
