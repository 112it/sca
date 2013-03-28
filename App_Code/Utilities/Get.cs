using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Xml.Linq;

namespace SharpComAdmin.Utilities
{
	public static class Get
	{
		/* Return strings */
		public static string String(string s, string DefaultValue = "")
		{
			return s == null ? DefaultValue : s;
		}
		public static string String(object o, string DefaultValue = "")
		{
			return o == null ? DefaultValue : o.ToString();
		}

		/* Return int */
		public static int Int(string s, int DefaultValue = 0)
		{
			try
			{
				if (s != null)
				{
					int i;
					if (int.TryParse(Regex.Replace(s, @"[^0-9\-]", ""), out i))
						return i;
				}
			}
			catch { }

			return DefaultValue;
		}
		public static int Int(object o, int DefaultValue = 0)
		{
			return o == null ? DefaultValue : Get.Int(o.ToString());
		}

		/* Return double */
		public static double Double(string s, double DefaultValue = 0d)
		{
			try
			{
				if (s != null)
				{
					double d;
					if (double.TryParse(Regex.Replace(s, @"[^0-9\-\.]", ""), out d))
						return d;
				}
			}
			catch { }

			return DefaultValue;
		}
		public static double Double(object o, double DefaultValue = 0d)
		{
			return o == null ? DefaultValue : Get.Double(o.ToString());
		}

		/* Return decimal */
		public static decimal Decimal(string s, decimal DefaultValue = 0m)
		{
			try
			{
				if (s != null)
				{
					decimal d;
					if (decimal.TryParse(Regex.Replace(s, @"[^0-9\-\.]", ""), out d))
						return d;
				}
			}
			catch { }

			return DefaultValue;
		}
		public static decimal Decimal(object o, decimal DefaultValue = 0m)
		{
			return o == null ? DefaultValue : Get.Decimal(o.ToString());
		}

		/* Return date */
		public static DateTime? Date(string s, DateTime? DefaultValue = null)
		{
			try
			{
				if (s != null)
				{
					DateTime d;
					if (DateTime.TryParse(s, out d))
						return d;
				}
			}
			catch { }

			return DefaultValue;
		}
		public static DateTime? Date(object o, DateTime? DefaultValue = null)
		{
			return o == null ? DefaultValue : Get.Date(o.ToString());
		}

		/* XElement */
		public static string XString(XElement XE, string attribute, string defaultValue = "")
		{
			if (XE == null)
				return defaultValue;
			else if (XE.Attribute(attribute) == null)
				return defaultValue;
			else
				return XE.Attribute(attribute).Value;
		}
		public static int XInt(XElement XE, string attribute, int defaultValue = 0)
		{
			if (XE == null)
				return defaultValue;
			else if (XE.Attribute(attribute) == null)
				return defaultValue;
			else
				return Int(XE.Attribute(attribute).Value, defaultValue);
		}
		public static double XDouble(XElement XE, string attribute, double defaultValue = 0d)
		{
			if (XE == null)
				return defaultValue;
			else if (XE.Attribute(attribute) == null)
				return defaultValue;
			else
				return Double(XE.Attribute(attribute).Value, defaultValue);
		}
		public static decimal XDecimal(XElement XE, string attribute, decimal defaultValue = 0m)
		{
			if (XE == null)
				return defaultValue;
			else if (XE.Attribute(attribute) == null)
				return defaultValue;
			else
				return Decimal(XE.Attribute(attribute).Value, defaultValue);
		}
		public static DateTime? XDate(XElement XE, string attribute, DateTime? defaultValue = null)
		{
			if (XE == null)
				return defaultValue;
			else if (XE.Attribute(attribute) == null)
				return defaultValue;
			else
				return Date(XE.Attribute(attribute).Value, defaultValue);
		}

		/* XElement value */
		public static string XVString(XElement XE, string defaultValue = "")
		{
			if (XE == null)
				return defaultValue;
			else
				return XE.Value;
		}
		public static int XVInt(XElement XE, int defaultValue = 0)
		{
			if (XE == null)
				return defaultValue;
			else
				return Int(XE.Value, defaultValue);
		}
		public static double XVDouble(XElement XE, double defaultValue = 0d)
		{
			if (XE == null)
				return defaultValue;
			else
				return Double(XE.Value, defaultValue);
		}
		public static decimal XVDecimal(XElement XE, decimal defaultValue = 0m)
		{
			if (XE == null)
				return defaultValue;
			else
				return Decimal(XE.Value, defaultValue);
		}
		public static DateTime? XVDate(XElement XE, DateTime? defaultValue = null)
		{
			if (XE == null)
				return defaultValue;
			else
				return Date(XE.Value, defaultValue);
		}

		public static string GetString(this XElement XE, string attribute, string defaultValue = "")
		{
			if (XE == null)
				return defaultValue;
			else if (XE.Attribute(attribute) == null)
				return defaultValue;
			else
				return XE.Attribute(attribute).Value;
		}
		public static int GetInt(this XElement XE, string attribute, int defaultValue = 0)
		{
			if (XE == null)
				return defaultValue;
			else if (XE.Attribute(attribute) == null)
				return defaultValue;
			else
				return Int(XE.Attribute(attribute).Value, defaultValue);
		}
		public static double GetDouble(this XElement XE, string attribute, double defaultValue = 0d)
		{
			if (XE == null)
				return defaultValue;
			else if (XE.Attribute(attribute) == null)
				return defaultValue;
			else
				return Double(XE.Attribute(attribute).Value, defaultValue);
		}
		public static decimal GetDecimal(this XElement XE, string attribute, decimal defaultValue = 0m)
		{
			if (XE == null)
				return defaultValue;
			else if (XE.Attribute(attribute) == null)
				return defaultValue;
			else
				return Decimal(XE.Attribute(attribute).Value, defaultValue);
		}
		public static DateTime? GetDate(this XElement XE, string attribute, DateTime? defaultValue = null)
		{
			if (XE == null)
				return defaultValue;
			else if (XE.Attribute(attribute) == null)
				return defaultValue;
			else
				return Date(XE.Attribute(attribute).Value, defaultValue);
		}

		public static string BreakRows(this string s)
		{
			return s.Replace("\n", "<br/>").Replace(Environment.NewLine, "<br/>");
		}
		public static string TrimString(this string s, int length)
		{
			s = s.BreakRows();

			if (s.Length < length)
				return s;

			s = s.Substring(0, length);

			int lastWordPos = s.LastIndexOf(" ");
			if (lastWordPos > -1)
				return string.Concat(s.Substring(0, lastWordPos), " ...");
			else
				return s;
		}

		public static void RemoveAll<T, V>(this Dictionary<T, V> dictionary, Func<KeyValuePair<T, V>, bool> predicate)
		{
			foreach (var de in dictionary.Where(predicate).ToList())
				dictionary.Remove(de.Key);
		}
	}
}