/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.typedescriptions
{
	import avmplus.getQualifiedClassName;

	import flash.utils.Dictionary;

	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.errors.InjectorMissingMappingError;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	import org.swiftsuspenders.utils.SsInternal;

	public class MethodInjectionPoint extends InjectionPoint
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private static const _parameterValues : Array = [];
		
		protected var _parameterMappingIDs : Array;
		protected var _requiredParameters : int;

		private var _isOptional : Boolean;
		private var _methodName : String;

		//----------------------               Public Methods               ----------------------//
		public function MethodInjectionPoint(methodName : String, parameters : Array,
			requiredParameters : uint, isOptional : Boolean, injectParameters : Dictionary)
		{
			_methodName = methodName;
			_parameterMappingIDs = parameters;
			_requiredParameters = requiredParameters;
			_isOptional = isOptional;
			this.injectParameters = injectParameters;
		}
		
		override public function applyInjection(
				target : Object, targetType : Class, injector : Injector) : void
		{
			var p : Array = gatherParameterValues(target, targetType, injector);
			if (p.length >= _requiredParameters)
			{
				(target[_methodName] as Function).apply(target, p);
			}

			p.length = 0;
		}

		//----------------------         Private / Protected Methods        ----------------------//
		protected function gatherParameterValues(
				target : Object, targetType : Class, injector : Injector) : Array
		{
			var length : int = _parameterMappingIDs.length;
			var parameters : Array = _parameterValues;
			parameters.length = length;
			for (var i : int = 0; i < length; i++)
			{
				var parameterMappingId : String = _parameterMappingIDs[i];
				var provider : DependencyProvider =
					injector.SsInternal::getProvider(parameterMappingId);
				if (!provider)
				{
					if (i >= _requiredParameters || _isOptional)
					{
						break;
					}
					throw(new InjectorMissingMappingError(
						'Injector is missing a mapping to handle injection into target "' +
						target + '" of type "' + getQualifiedClassName(targetType) + '". \
						Target dependency: ' + parameterMappingId +
						', method: ' + _methodName + ', parameter: ' + (i + 1)
					));
				}
				
				parameters[i] = provider.apply(targetType, injector, injectParameters);
			}
			return parameters;
		}
	}
}