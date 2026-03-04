
namespace UNI.Resident.Model.Request
{
    public record UserAssignType
    {
        public string UserId { get; set; }
        public int AssignRole { get; set; }
        public bool Used { get; set; }
    }
}
