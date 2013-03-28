using System;
using System.Web.Security;
using System.Web.UI;

public partial class Sections_FrontStore_product : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
		string sessionKey = Guid.NewGuid().ToString("n");
		key.Value = sessionKey;

		if (!ClientScript.IsClientScriptBlockRegistered(typeof(Page), "SessionAuthData"))
			ClientScript.RegisterClientScriptBlock(
				typeof(Page),
				"SessionAuthData",
				string.Format(
					"$SD={{S:'{0}',F:'{1}',TF:'{2}'}};",
					Session.SessionID,
					FormsAuthentication.IsEnabled && Request.Cookies[FormsAuthentication.FormsCookieName] != null ? Request.Cookies[FormsAuthentication.FormsCookieName].Value : string.Empty,
					sessionKey
				),
				true
			);
	}
}