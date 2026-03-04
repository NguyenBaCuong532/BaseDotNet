using Dapper;
using System.Linq;
using UNI.Common.CommonBase;

namespace UNI.Resident.DAL.Commons
{
    public interface IResidentBaseRepository : IUniBaseRepository
    {
        public string ProjectCode { get; }
    }

    public class ResidentBaseRepository : UniBaseRepository, IResidentBaseRepository
    {
        private readonly IResidentCommonBaseRepository residentCommon;
        private readonly bool _autoSetProjectCode;
        public ResidentBaseRepository(IResidentCommonBaseRepository common, bool autoSetProjectCode = true) : base(common)
        {
            residentCommon = common;
            _autoSetProjectCode = autoSetProjectCode;
        }

        public string ProjectCode => residentCommon.ProjectCode;

        public override DynamicParameters GetParameters(DynamicParameters param = null, object objParams = null, ParametersHandler parametersHandler = null)
        {
            var dynamicParam = base.GetParameters(param, objParams, parametersHandler);
            if (_autoSetProjectCode)
            {
                var lsParamName = dynamicParam.ParameterNames.Select(s => s).ToList();
                if (lsParamName.FirstOrDefault(s => s.ToLower() == "project_code".ToLower()) == null)
                    dynamicParam.Add("project_code", residentCommon.ProjectCode);
            }
            return dynamicParam;
        }

        public override void AddDynamicParams(DynamicParameters param, object objParams)
        {
            base.AddDynamicParams(param, objParams);

            if (_autoSetProjectCode)
            {
                var lsParamName = param.ParameterNames.Select(s => s).ToList();
                if (lsParamName.FirstOrDefault(s => s.ToLower() == "project_code".ToLower()) == null)
                    param.Add("project_code", residentCommon.ProjectCode);
            }
        }
    }
}