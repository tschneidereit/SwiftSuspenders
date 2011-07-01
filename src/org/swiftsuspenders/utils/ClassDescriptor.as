/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.utils
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	import org.swiftsuspenders.Reflector;
	import org.swiftsuspenders.injectionpoints.InjectionPoint;

	public class ClassDescriptor
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _descriptionsCache : Dictionary;
		private var _reflector : Reflector;


		//----------------------               Public Methods               ----------------------//
		public function ClassDescriptor(descriptionsCache : Dictionary, reflector : Reflector)
		{
			_descriptionsCache = descriptionsCache;
			_reflector = reflector;
		}

		public function getDescription(type : Class) : ClassDescription
		{
			//get injection points or cache them if this target's class wasn't encountered before
			return _descriptionsCache[type] ||= createDescription(type);
		}

		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function getDescriptionXML(type : Class) : XML
		{
			return describeType(type);
		}
		
		private function createDescription(type : Class) : ClassDescription
		{
			_reflector.startReflection(type);
			const ctorInjectionPoint : InjectionPoint = _reflector.getCtorInjectionPoint();
			const injectionPoints : Array = [];
			_reflector.addFieldInjectionPointsToList(injectionPoints);
			_reflector.addMethodInjectionPointsToList(injectionPoints);
			_reflector.addPostConstructMethodPointsToList(injectionPoints);
			_reflector.endReflection();

			return new ClassDescription(type, ctorInjectionPoint, injectionPoints);
		}
	}
}