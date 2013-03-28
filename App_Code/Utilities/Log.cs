using System;
using System.Configuration;
using System.IO;

namespace SharpComAdmin.Utilities
{
	public static class Log
	{
		private static string sExceptionsLogFile = null;
		private static string sDebugInfoLogFile = null;

		static string lockDebugControl = "Debug";
		static string lockExceptionControl = "Exception";

		public static void DebugInfo(string s, string sFileSuffix)
		{
			try
			{
				if (sDebugInfoLogFile == null)
					sDebugInfoLogFile = ConfigurationManager.AppSettings["DebugInfoLogFile"];

				int iB = sDebugInfoLogFile.LastIndexOf('.');
				string sF = iB > -1 ? (sDebugInfoLogFile.Substring(0, iB) + "-" + sFileSuffix + sDebugInfoLogFile.Substring(iB)) : ("-" + sFileSuffix);

				lock (lockDebugControl)
				{
					using (StreamWriter sw = new StreamWriter(sF, true))
					{
						sw.WriteLine(DateTime.Now.ToString() + ":" + DateTime.Now.Millisecond + "\t" + s + "\r\n\r\n");
						sw.Close();
					}
				}
			}
			catch { }
		}

		public static void Exception(Exception e, string sFileSuffix)
		{
			try
			{
				if (sExceptionsLogFile == null)
					sExceptionsLogFile = ConfigurationManager.AppSettings["ExceptionsLogFile"];

				int iB = sExceptionsLogFile.LastIndexOf('.');
				string sF = iB > -1 ? (sExceptionsLogFile.Substring(0, iB) + "-" + sFileSuffix + sExceptionsLogFile.Substring(iB)) : ("-" + sFileSuffix);

				lock (lockExceptionControl)
				{
					using (StreamWriter sw = new StreamWriter(sF, true))
					{
						sw.WriteLine
						(
							DateTime.Now.ToString() + ":" + DateTime.Now.Millisecond
							+ "\r\nMessage: " + e.Message
							+ "\r\nSource: " + e.Source
							+ "\r\nTargetSite: " + e.TargetSite
							+ "\r\nStackTrace:\r\n" + e.StackTrace
							+ "\r\n\r\n"
						);
						sw.Close();
					}
				}
			}
			catch { }
		}
	}
}