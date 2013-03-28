using System;
using System.Web;
using System.Web.SessionState;

namespace SharpComAdmin.Handlers
{
	public class image_uploader : IHttpHandler, IReadOnlySessionState
	{
		public void ProcessRequest(HttpContext context)
		{
			context.Response.ContentType = "application/json";

			HttpPostedFile file = context.Request.Files["picture"];
			string temporaryFolder = context.Request.Form["TF"];

			context.Response.Write(string.Format(
				"{{id:'{0}',s:'{1}'}}",
				Guid.NewGuid().ToString("n"),
				temporaryFolder
			));
			//System.Threading.Thread.Sleep(2000);
		}

		public bool IsReusable { get { return false; } }
	}
}