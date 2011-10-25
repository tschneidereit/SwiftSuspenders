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
	import org.swiftsuspenders.injectionpoints.ConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPoint;

	public class ClassDescriptor
	{
		//----------------------       Private / Protected Properties       ----------------------//
		public var _descriptionsCache : Dictionary;
		private var _reflector : Reflector;


		//----------------------               Public Methods               ----------------------//
		public function ClassDescriptor(descriptionsCache : Dictionary)
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

		public function getDescription(type : Class) : ConstructorInjectionPoint
		{
			//get injection points or cache them if this target's class wasn't encountered before
			return _descriptionsCache[type] ||= createDescription(type);
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createDescription(type : Class) : ConstructorInjectionPoint
		{
			_reflector.startReflection(type);
			const ctorInjectionPoint : ConstructorInjectionPoint =
					_reflector.getCtorInjectionPoint();
			var lastInjectionPoint : InjectionPoint = ctorInjectionPoint;
			lastInjectionPoint = _reflector.addFieldInjectionPointsToList(lastInjectionPoint);
			lastInjectionPoint = _reflector.addMethodInjectionPointsToList(lastInjectionPoint);
			lastInjectionPoint = _reflector.addPostConstructMethodPointsToList(lastInjectionPoint);
			_reflector.endReflection();

			return ctorInjectionPoint;
		}
	}
}