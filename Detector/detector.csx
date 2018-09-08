#region Framework References and Imports (Do not add or remove anything here)
#load "../Framework/_frameworkRef.csx"
using System;
using System.Linq;
using System.Data;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using Diagnostics.DataProviders;
using Diagnostics.ModelsAndUtils;
using Diagnostics.ModelsAndUtils.Attributes;
using Diagnostics.ModelsAndUtils.Models;
using Diagnostics.ModelsAndUtils.Models.ResponseExtensions;
using Diagnostics.ModelsAndUtils.ScriptUtilities;

#endregion

private static string GetQuery(OperationContext<App> cxt)
{
    return
    $@"<YOUR_TABLE_NAME>
        | where {Utilities.TimeAndTenantFilterQuery(cxt.StartTime, cxt.EndTime, cxt.Resource)}
        | <YOUR_QUERY>";
}

[AppFilter(AppType = AppType.WebApp, PlatformType = PlatformType.Windows, StackType = StackType.All)]
[Definition(Id = "<YOUR_DETECTOR_ID>", Name = "", Author = "<YOUR_ALIAS>", Description = "")]
public async static Task<Response> Run(DataProviders dp, OperationContext<App> cxt, Response res)
{
    new Insight(InsightStatus.Critical, "");
    res.AddMarkdownView("fewe", "");
    return res;
}





























































