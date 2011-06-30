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

		private var _injectionIsOptional : Boolean;
		private var _methodName : String;


		//----------------------               Public Methods               ----------------------//
		public function MethodInjectionPoint(node : XML)
		{
			initializeInjection(node);
		}
		
		override public function applyInjection(target : Object, injector : Injector) : Object
		{
			var parameters : Array = gatherParameterValues(target, injector);
			if (!parameters && _injectionIsOptional)
			{
				return target;
			}
			var method : Function = target[_methodName];
			method.apply(target, parameters);
			return target;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		protected function initializeInjection(node : XML) : void
		{
			var nameArgs : XMLList = node.arg.(@key == 'name');
			var methodNode : XML = node.parent();
			_methodName = methodNode.@name;
			_injectionIsOptional = node.arg.(@key == 'optional' &&
					(@value == 'true' || @value == '1')).length() != 0;
			
			gatherParameters(methodNode, nameArgs);
		}
		
		protected function gatherParameters(methodNode : XML, nameArgs : XMLList) : void
		{
			const parameterNodes : XMLList = methodNode.parameter;
			const length : uint = parameterNodes.length();
			_parameterInjectionConfigs = new Array(length);
			for (var i : int = 0; i < length; i++)
			{
				var parameter : XML = parameterNodes[i];
				var injectionName : String = '';
				if (nameArgs[i])
				{
					injectionName = nameArgs[i].@value;
				}
				var parameterTypeName : String = parameter.@type;
				if (parameterTypeName == '*')
				{
					if (parameter.@optional == 'false' || parameter.@optional == '0')
					{
						//TODO: Find a way to trace name of affected class here
						throw new InjectorError('Error in method definition of injectee. ' +
							'Required parameters can\'t have type "*".');
					}
					else
					{
						parameterTypeName = null;
					}
				}
				_parameterInjectionConfigs[i] =
						new InjectionPointConfig(parameterTypeName, injectionName, false);
				if (parameter.@optional == 'false')
				{
					_requiredParameters++;
				}
			}
		}
		
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
					if (_injectionIsOptional)
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