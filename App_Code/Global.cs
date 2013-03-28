using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.Security;
using SharpComAdmin.Utilities;

namespace SharpComAdmin
{
	public class Global : System.Web.HttpApplication
	{
		void Application_Start(object sender, EventArgs e)
		{
		}

		void Application_End(object sender, EventArgs e)
		{
		}

		void Application_Error(object sender, EventArgs e)
		{
		}

		void Session_Start(object sender, EventArgs e)
		{
		}

		void Session_End(object sender, EventArgs e)
		{
		}

		void Application_BeginRequest(object sender, EventArgs e)
		{
			//setup session and authentication cookies
			if (HttpContext.Current.Request.Path.EndsWith("image_uploader.ashx", StringComparison.InvariantCultureIgnoreCase))
			{
				try
				{
					SessionStateSection sessionStateSection = (SessionStateSection)ConfigurationManager.GetSection("system.web/sessionState");
					HttpContext.Current.Response.Cookies.Set(new HttpCookie(sessionStateSection.CookieName, HttpContext.Current.Request.Form["_S"]));
				}
				catch { }

				try
				{
					if (FormsAuthentication.IsEnabled)
						HttpContext.Current.Response.Cookies.Set(new HttpCookie(FormsAuthentication.FormsCookieName, HttpContext.Current.Request.Form["_F"]));
				}
				catch { }
			}
		}
	}
}