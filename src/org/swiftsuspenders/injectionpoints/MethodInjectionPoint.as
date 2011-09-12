/*
 * Copyright (c) 2009-2011 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import org.swiftsuspenders.InjectionRule;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.InjectorError;
	import org.swiftsuspenders.utils.SsInternal;

	public class MethodInjectionPoint extends InjectionPoint
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _parameterInjectionConfigs : Array;
		protected var _requiredParameters : int = 0;

		private var _isOptional : Boolean;
		private var _methodName : String;


		//----------------------               Public Methods               ----------------------//
		public function MethodInjectionPoint(
				methodName : String, parameters : Array, isOptional : Boolean)
		{
			_methodName = methodName;
			_isOptional = isOptional;
			_parameterInjectionConfigs = parameters;
			for (var i : int = parameters.length; i--;)
			{
				var parameter : InjectionPointConfig = parameters[i];
				if (!parameter.optional)
				{
					_requiredParameters = i + 1;
					return;
				}
			}
		}
		
		override public function applyInjection(target : Object, injector : Injector) : Object
		{
			var parameters : Array = gatherParameterValues(target, injector);
			if (!parameters && _isOptional)
			{
				return target;
			}
			var method : Function = target[_methodName];
			method.apply(target, parameters);
			return target;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		protected function gatherParameterValues(target : Object, injector : Injector) : Array
		{
			var length : int = _parameterInjectionConfigs.length;
			var parameters : Array = new Array(length);
			for (var i : int = 0; i < length; i++)
			{
				var parameterConfig : InjectionPointConfig = _parameterInjectionConfigs[i];
				var rule : InjectionRule =
						injector.SsInternal::getRuleForInjectionPointConfig(parameterConfig);
				var injection : Object = rule && rule.apply(injector);
				if (injection == null)
				{
					if (i >= _requiredParameters)
					{
						break;
					}
					if (_isOptional)
					{
						return null;
					}
					throw(new InjectorError(
						'Injector is missing a rule to handle injection into target ' + target + 
						'. Target dependency: ' + parameterConfig.typeName +
						', method: ' + _methodName + ', parameter: ' + (i + 1)
					));
				}
				
				parameters[i] = injection;
			}
			return parameters;
		}
	}
}