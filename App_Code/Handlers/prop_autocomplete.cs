using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Caching;
using System.Xml;
using System.Xml.Linq;
using SharpComAdmin.Utilities;

namespace SharpComAdmin.Handlers
{
	public class prop_autocomplete : IHttpHandler
	{
		struct PACQuery
		{
			public DateTime SearchDate { get; set; }
			public List<string> SearchResult { get; set; }
		}
		readonly int KeepInCache = Get.Int(ConfigurationManager.AppSettings["PropertiesAutocompleteKeepInCache"], 30);

		public void ProcessRequest(HttpContext context)
		{
			context.Response.ContentType = "application/json";

			string propName = context.Request.Form["p"].Trim();
			string searchString = context.Request.Form["q"].Trim();
			List<string> exclude = new List<string>(context.Request.Form["e"].Split(new string[] { "|#|" }, StringSplitOptions.RemoveEmptyEntries));

			string cacheKey = string.Concat(propName, "|#|", searchString);
			bool cacheHit = false;
			List<string> result = new List<string>();

			if (string.IsNullOrEmpty(searchString))
			{
				context.Response.Write("[]");
				return;
			}

			Dictionary<string, PACQuery> pacQueries = new Dictionary<string, PACQuery>();
			var qc = context.Cache.Get("PACQueries");
			if (qc != null && qc.GetType().Equals(typeof(Dictionary<string, PACQuery>)))
			{
				pacQueries = qc as Dictionary<string, PACQuery>;

				//remove cache entries stored for longer than allowed time
				pacQueries.RemoveAll(k => DateTime.Now.Subtract(k.Value.SearchDate).TotalSeconds > KeepInCache);
			}

			//check and grab exact match from cache
			if (pacQueries.Any(k => k.Key.Equals(cacheKey)))
			{
				cacheHit = true;
				result.AddRange(pacQueries[cacheKey].SearchResult);
			}

			//check if closest partial search had zero results
			if (!cacheHit && pacQueries.Any(k => cacheKey.StartsWith(k.Key)))
			{
				PACQuery q = pacQueries.Where(k => cacheKey.StartsWith(k.Key)).OrderByDescending(k => k.Key.Length).First().Value;
				if (q.SearchResult.Count == 0)
					cacheHit = true;
			}

			//db search
			if (!cacheHit)
			{
				XDocument XResults = new XDocument();

				try
				{
					using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["SqlDbCon"].ConnectionString))
					{
						con.Open();
						using (SqlCommand cmd = con.CreateCommand())
						{
							cmd.CommandText = "Property_autocomplete";
							cmd.CommandType = CommandType.StoredProcedure;
							cmd.Parameters.Add(new SqlParameter("@property_name", SqlDbType.NVarChar, 250, ParameterDirection.Input, false, 0, 0, "property_name", DataRowVersion.Current, !string.IsNullOrEmpty(propName) ? propName : searchString));
							cmd.Parameters.Add(new SqlParameter("@property_value", SqlDbType.NVarChar, 250, ParameterDirection.Input, false, 0, 0, "property_value", DataRowVersion.Current, !string.IsNullOrEmpty(propName) ? searchString : string.Empty));
							using (XmlReader xr = cmd.ExecuteXmlReader())
							{
								xr.MoveToContent();
								XResults = XDocument.Load(xr);
								xr.Close();
							}
						}
					}
				}
				catch (Exception exc)
				{
					Log.Exception(exc, "PAC");
				}

				if (XResults.Root != null)
					XResults.Root.Descendants().ToList().ForEach(XR => { if (!result.Contains(XR.Value)) result.Add(XR.Value); });

				pacQueries.Add(cacheKey, new PACQuery { SearchDate = DateTime.Now, SearchResult = new List<string>(result) });

				//rebuild cache
				context.Cache.Remove("PACQueries");
				context.Cache.Add("PACQueries", pacQueries, null, Cache.NoAbsoluteExpiration, Cache.NoSlidingExpiration, CacheItemPriority.Normal, null);
			}

			//remove items marked as exclude from result
			foreach (var k in result.Intersect(exclude))
				result.Remove(k);

			context.Response.Write("[\"");
			context.Response.Write(string.Join("\",\"", result.ToArray()));
			context.Response.Write("\"]");
		}

		public bool IsReusable { get { return false; } }
	}
}