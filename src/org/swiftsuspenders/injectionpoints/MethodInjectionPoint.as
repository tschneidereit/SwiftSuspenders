/*
 * Copyright (c) 2009 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.InjectorError;

	public class MethodInjectionPoint extends InjectionPoint
	{
		/*******************************************************************************************
		*								private properties										   *
		*******************************************************************************************/
		protected var methodName : String;
		protected var m_injectionConfigs : Array;
		protected var requiredParameters : int = 0;
		
		
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function MethodInjectionPoint(node : XML, injector : Injector)
		{
			super(node, injector);
		}
		
		override public function applyInjection(target : Object, injector : Injector) : Object
		{
			var parameters : Array = gatherParameterValues(target, injector);
			var method : Function = target[methodName];
			method.apply(target, parameters);
			return target;
		}


		/*******************************************************************************************
		*								protected methods										   *
		*******************************************************************************************/
		override protected function initializeInjection(node : XML, injector : Injector) : void
		{
			var nameArgs : XMLList = node.arg.(@key == 'name');
			var methodNode : XML = node.parent();
			methodName = methodNode.@name.toString();
			
			gatherParameters(methodNode, nameArgs, injector);
		}
		
		protected function gatherParameters(
			methodNode : XML, nameArgs : XMLList, injector : Injector) : void
		{
			m_injectionConfigs = [];
			var i : int = 0;
			for each (var parameter : XML in methodNode.parameter)
			{
				var injectionName : String = '';
				if (nameArgs[i])
				{
					injectionName = nameArgs[i].@value.toString();
				}
				var parameterTypeName : String = parameter.@type.toString();
				var parameterType : Class;
				if (parameterTypeName == '*')
				{
					if (parameter.@optional.toString() == 'false')
					{
						//TODO: Find a way to trace name of affected class here
						throw new Error('Error in method definition of injectee. Required ' + 
							'parameters can\'t have type "*".');
					}
					else
					{
						parameterTypeName = null;
					}
				}
				else
				{
					parameterType = Class(injector.getApplicationDomain().getDefinition(parameterTypeName));
				}
				m_injectionConfigs.push(injector.getMapping(parameterType, injectionName));
				if (parameter.@optional.toString() == 'false')
				{
					requiredParameters++;
				}
				i++;
			}
		}
		
		protected function gatherParameterValues(target : Object, injector : Injector) : Array
		{
			var parameters : Array = [];
			var length : int = m_injectionConfigs.length;
			for (var i : int = 0; i < length; i++)
			{
				var config : InjectionConfig = m_injectionConfigs[i];
				var injection : Object = config.getResponse(injector);
				if (injection == null)
				{
					if (i >= requiredParameters)
					{
						break;
					}
					throw(new InjectorError(
						'Injector is missing a rule to handle injection into target ' + target + 
						'. Target dependency: ' + getQualifiedClassName(config.request) + 
						', method: ' + methodName + ', parameter: ' + (i + 1)
					));
				}
				
				parameters[i] = injection;
			}
			return parameters;
		}
	}
}