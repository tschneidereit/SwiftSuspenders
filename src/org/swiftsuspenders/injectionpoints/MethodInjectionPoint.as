/*
 * Copyright (c) 2009-2011 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import flash.system.ApplicationDomain;

	import org.swiftsuspenders.InjectionRule;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.InjectorError;

	public class MethodInjectionPoint extends InjectionPoint
	{
		/*******************************************************************************************
		*								private properties										   *
		*******************************************************************************************/
		protected var _parameterInjectionConfigs : Array;
		protected var _requiredParameters : int = 0;

		private var _injectionIsOptional : Boolean;
		private var _methodName : String;

		
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function MethodInjectionPoint(node : XML)
		{
			super(node);
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


		/*******************************************************************************************
		*								protected methods										   *
		*******************************************************************************************/
		override protected function initializeInjection(node : XML) : void
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
			_parameterInjectionConfigs = [];
			var i : int = 0;
			for each (var parameter : XML in methodNode.parameter)
			{
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
				_parameterInjectionConfigs.push(
						new ParameterInjectionConfig(parameterTypeName, injectionName));
				if (parameter.@optional == 'false')
				{
					_requiredParameters++;
				}
				i++;
			}
		}
		
		protected function gatherParameterValues(target : Object, injector : Injector) : Array
		{
			var appDomain : ApplicationDomain = injector.getApplicationDomain();
			var parameters : Array = [];
			var length : int = _parameterInjectionConfigs.length;
			for (var i : int = 0; i < length; i++)
			{
				var parameterConfig : ParameterInjectionConfig = _parameterInjectionConfigs[i];
				var rule : InjectionRule = injector.getMapping(
						Class(appDomain.getDefinition(parameterConfig.typeName)),
						parameterConfig.injectionName);
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

final class ParameterInjectionConfig
{
	public var typeName : String;
	public var injectionName : String;

	public final function ParameterInjectionConfig(typeName : String, injectionName : String)
	{
		this.typeName = typeName;
		this.injectionName = injectionName;
	}
}