namespace UNI.Resident.Model.Feedback
{
    public class Feedback
    {
        public int FeedbackId { get; set; }
        public string ProjectName { get; set; }
        public string RoomCode { get; set; }
        public string FullName { get; set; }
        public string FeedbackTypeName { get; set; }
        public string Title { get; set; }
        public string Comment { get; set; }
        public string FeedbackDate { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; }
    }
}
