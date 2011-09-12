package org.swiftsuspenders
{
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.utils.getConstructor;

	public class ReflectorBase
	{
		//----------------------              Public Properties             ----------------------//


		//----------------------       Private / Protected Properties       ----------------------//


		//----------------------               Public Methods               ----------------------//
		public function ReflectorBase()
		{
		}

		public function getClass(value : *, applicationDomain : ApplicationDomain = null) : Class
		{
			if (value is Class)
			{
				return value;
			}
			return getConstructor(value);
		}

		public function getFQCN(value : *, replaceColons : Boolean = false) : String
		{
			var fqcn : String;
			if (value is String)
			{
				fqcn = value;
				// Add colons if missing and desired.
				if (!replaceColons && fqcn.indexOf('::') == -1)
				{
					var lastDotIndex : int = fqcn.lastIndexOf('.');
					if (lastDotIndex == -1)
					{
						return fqcn;
					}
					return fqcn.substring(0, lastDotIndex) + '::' +
							fqcn.substring(lastDotIndex + 1);
				}
			}
			else
			{
				fqcn = getQualifiedClassName(value);
			}
			return replaceColons ? fqcn.replace('::', '.') : fqcn;
		}

		//----------------------         Private / Protected Methods        ----------------------//
	}
}