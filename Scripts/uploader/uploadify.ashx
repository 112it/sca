<%@ WebHandler Language="C#" Class="uploadify" %>

using System;
using System.Web;
using System.Web.SessionState;
//using Entities.Utilities;

public class uploadify : IHttpHandler, IReadOnlySessionState
{
	public void ProcessRequest(HttpContext context)
	{
		//context.Response.ContentType = "text/html";

		//HttpPostedFile file = context.Request.Files["image"];
		//string picturesTempFileKey = context.Request.Form["ptfk"];
		//int uID = Get.Int(context.Request.Form["uid"]);
		//string uIP = context.Request.Form["uip"];

		////if (Config.LoggedUser.UserID != uID)
		////{
		////    context.Response.Write("UserID is missing or invalid!");
		////    context.Response.StatusCode = 500;
		////    Log.Exception(new Exception(string.Format("There was an upload request from IP {0} with missing or invalid UserID {1}! Expecting {2}-{3}.", context.Request.UserHostAddress, uID, Config.LoggedUser.UserID, Config.LoggedUser.UserName)));
		////    return;
		////}

		//if (!context.Request.UserHostAddress.Equals(uIP))
		//{
		//	context.Response.Write("UserID is missing or invalid!");
		//	context.Response.StatusCode = 500;
		//	Log.Exception(new Exception(string.Format("There was an upload request from IP {0} with missing or invalid UserIP {1}!", context.Request.UserHostAddress, uIP)));
		//	return;
		//}

		//if (file == null)
		//{
		//	context.Response.Write("File is missing!");
		//	context.Response.StatusCode = 500;
		//	Log.Exception(new Exception(string.Format("There was an upload request from IP {0} with missing file!", context.Request.UserHostAddress)));
		//	return;
		//}

		//if (string.IsNullOrEmpty(picturesTempFileKey))
		//{
		//	context.Response.Write("PTFK is missing!");
		//	context.Response.StatusCode = 500;
		//	Log.Exception(new Exception(string.Format("There was an upload request from IP {0} with missing PTFK!", context.Request.UserHostAddress)));
		//	return;
		//}

		////fucked-up -> comes as "application/octet-stream"
		////if (!file.ContentType.Contains("image"))
		////{
		////    context.Response.Write("Invalid file type!");
		////    context.Response.StatusCode = 500;
		////    Log.Exception(new Exception(string.Format("There was an upload request from IP {0} with the invalid type {1}!", context.Request.UserHostAddress, file.ContentType)));
		////    return;
		////}

		//if (file.ContentLength == 0 || file.ContentLength > 10485760)
		//{
		//	context.Response.Write("Invalid file size!");
		//	context.Response.StatusCode = 500;
		//	Log.Exception(new Exception(string.Format("There was an upload request from IP {0} with the invalid size {1}!", context.Request.UserHostAddress, file.ContentLength)));
		//	return;
		//}

		//try
		//{
		//	string response = PicturesHandler.Upload(file.InputStream, picturesTempFileKey);
		//	if (!string.IsNullOrEmpty(response))
		//		context.Response.Write(response);
		//	else
		//		throw new Exception("Something wrong happend inside the PicturesHandler!");
		//}
		//catch (Exception exc)
		//{
		//	Log.Exception(exc);
		//	Log.Exception(new Exception(string.Format("There was an upload failure - IP: {0}, PTFK: {1}, Name: {2}", context.Request.UserHostAddress, picturesTempFileKey, file.FileName)));
		//	context.Response.Write("Upload failed!");
		//	context.Response.StatusCode = 500;
		//}
	}

	public bool IsReusable { get { return false; } }
}