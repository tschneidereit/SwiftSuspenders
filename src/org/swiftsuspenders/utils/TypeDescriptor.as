/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.utils
{
	import avmplus.DescribeTypeJSON;

	import flash.utils.Dictionary;

	import org.swiftsuspenders.DescribeTypeJSONReflector;
	import org.swiftsuspenders.DescribeTypeReflector;
	import org.swiftsuspenders.Reflector;
	import org.swiftsuspenders.typedescriptions.TypeDescription;

	public class TypeDescriptor
	{
		//----------------------       Private / Protected Properties       ----------------------//
		public var _descriptionsCache : Dictionary;
		private var _reflector : Reflector;


		//----------------------               Public Methods               ----------------------//
		public function TypeDescriptor(descriptionsCache : Dictionary)
		{
			_descriptionsCache = descriptionsCache;
			try
			{
				_reflector = DescribeTypeJSON.available
					? new DescribeTypeJSONReflector()
					: new DescribeTypeReflector();
			}
			catch (e:Error)
			{
				_reflector = new DescribeTypeReflector();
			}
		}

		public function getDescription(type : Class) : TypeDescription
		{
			//get type description or cache it if the given type wasn't encountered before
			return _descriptionsCache[type] ||= _reflector.describeInjections(type);
		}
	}
}