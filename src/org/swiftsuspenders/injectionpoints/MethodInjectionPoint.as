/*
 * Copyright (c) 2009-2011 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import avmplus.getQualifiedClassName;

	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.InjectorError;

	public class MethodInjectionPoint extends InjectionPoint
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private static const _parameterValues : Array = [];
		
		protected var _parameterInjectionConfigs : Array;
		protected var _requiredParameters : int;

		private var _isOptional : Boolean;
		private var _methodName : String;


		//----------------------               Public Methods               ----------------------//
		public function MethodInjectionPoint(methodName : String, parameters : Array,
		                                     requiredParameters : uint, isOptional : Boolean)
		{
			_methodName = methodName;
			_parameterInjectionConfigs = parameters;
			_requiredParameters = requiredParameters;
			_isOptional = isOptional;
		}
		
		override public function applyInjection(
				target : Object, targetType : Class, injector : Injector) : void
		{
			var p : Array = gatherParameterValues(target, targetType, injector);
			if (p.length >= _requiredParameters)
			{
				switch (p.length)
				{
					case 0 : (target[_methodName] as Function)(); break;
					case 1 : (target[_methodName] as Function)(p[0]); break;
					case 2 : (target[_methodName] as Function)(p[0], p[1]); break;
					case 3 : (target[_methodName] as Function)(p[0], p[1], p[2]); break;
					default: (target[_methodName] as Function).apply(target, p);
				}
			}

			p.length = 0;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		protected function gatherParameterValues(
				target : Object, targetType : Class, injector : Injector) : Array
		{
			var length : int = _parameterInjectionConfigs.length;
			var parameters : Array = _parameterValues;
			parameters.length = length;
			for (var i : int = 0; i < length; i++)
			{
				var parameterConfig : InjectionPointConfig = _parameterInjectionConfigs[i];
				var injection : Object = parameterConfig.apply(targetType, injector);
				if (injection == null)
				{
					if (i >= _requiredParameters || _isOptional)
					{
						break;
					}
					throw(new InjectorError(
						'Injector is missing a rule to handle injection into target "' + target +
						'" of type "' + getQualifiedClassName(targetType) + '". \
						Target dependency: ' + parameterConfig.mappingId +
						', method: ' + _methodName + ', parameter: ' + (i + 1)
					));
				}
				
				parameters[i] = injection;
			}
			return parameters;
		}
	}
}