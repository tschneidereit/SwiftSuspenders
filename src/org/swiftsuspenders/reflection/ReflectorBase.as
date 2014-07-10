/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.reflection
{
	import flash.utils.Proxy;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ReflectorBase
	{
		//----------------------              Public Properties             ----------------------//

		//----------------------               Public Methods               ----------------------//
		public function ReflectorBase()
		{
		}

		public function getClass(value : Object) : Class
		{
			/*
			 There are several types for which the 'constructor' property doesn't work:
			 - instances of Proxy, XML and XMLList throw exceptions when trying to access 'constructor'
			 - instances of Vector, always returns Vector.<*> as their constructor except numeric vectors
			 - for numeric vectors 'value is Vector.<*>' wont work, but 'value.constructor' will return correct result
			 - int and uint return Number as their constructor
			 For these, we have to fall back to more verbose ways of getting the constructor.
			 */
			if (value is Proxy || value is Number || value is XML || value is XMLList || value is Vector.<*>)
			{
				return Class(getDefinitionByName(getQualifiedClassName(value)));
			}
			return value.constructor;
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