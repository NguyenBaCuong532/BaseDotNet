namespace UNI.Resident.Model.Request
{
    public record RequestAttachment
    {
        public long Id { get; set; }
        public long RequestId { get; set; }
        public long ProcessId { get; set; }
        public string AttachUrl { get; set; }
        public string AttachType { get; set; }
        public string AttachFileName { get; set; }
        public bool Used { get; set; }
    }
    public record RequestAttachmentType : RequestAttachment { }
}
