/*
 * Copyright (c) 2009-2011 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.InjectorError;
	import org.swiftsuspenders.utils.SsInternal;

	public class PropertyInjectionPoint extends InjectionPoint
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _propertyName : String;
		private var _mappingId : String;
		private var _optional : Boolean;


		//----------------------               Public Methods               ----------------------//
		public function PropertyInjectionPoint(
				mappingId : String, propertyName : String, optional : Boolean)
		{
			_propertyName = propertyName;
			_mappingId = mappingId;
			_optional = optional;
		}
		
		override public function applyInjection(
				target : Object, targetType : Class, injector : Injector) : void
		{
			var injection : Object = injector.SsInternal::applyMapping(targetType, _mappingId);
			if (injection == null)
			{
				if (_optional)
				{
					return;
				}
				throw(new InjectorError(
						'Injector is missing a mapping to handle injection into property "' +
						_propertyName + '" of object "' + target + '" with type "' + targetType +
						'". Target dependency: "' + _mappingId + '"'));
			}
			target[_propertyName] = injection;
		}
	}
}