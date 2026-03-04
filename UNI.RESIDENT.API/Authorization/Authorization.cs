using System.Collections.Generic;
using Newtonsoft.Json;

namespace UNI.Resident.API.Authorization
{
    public class Authorization
    {
        [JsonProperty("permissions")]
        public List<Permission> Permissions { get; set; }
    }

    public class Role
    {
        [JsonProperty("roles")]
        public List<string> Roles { get; set; }
    }

    public class Permission
    {
        [JsonProperty("rsid")]
        public string ResourceId { get; set; }

        [JsonProperty("rsname")]
        public string ResourceName { get; set; }

        [JsonProperty("scopes")]
        public List<string> Scopes { get; set; }
    }
}
