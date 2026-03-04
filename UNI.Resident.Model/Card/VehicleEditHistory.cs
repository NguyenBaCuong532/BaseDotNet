namespace UNI.Resident.Model.Card
{
    public class VehicleEditHistory //: Countable
    {
        public int CardVehicleId { get; set; }
        public string CardCd { get; set; }
        public string VehicleNo { get; set; }
        public string VehicleName { get; set; }
        public string StartTimeRen { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        public string LockedDate { get; set; }
        public string RemovedDate { get; set; }
        public int Status { get; set; }

        public string RoomCode { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string AssignDate { get; set; }
        public int vehicleTypeId { get; set; }
        public string VehicleTypeName { get; set; }
        public string StatusName { get; set; }
        public bool IsLock { get; set; }
        public string CardTypeName { get; set; }
        public string CreateByName { get; set; }
        public string DeleteBy { get; set; }
        public string AddedBy { get; set; }
        public string PhoneExer { get; set; }
        public string LockedBy { get; set; }
        public string reason { get; set; }
    }
}
