/*
 * Copyright (c) 2009 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.InjectorError;

	public class MethodInjectionPoint extends InjectionPoint
	{
		/*******************************************************************************************
		*								private properties										   *
		*******************************************************************************************/
		protected var methodName : String;
		protected var mappings : Array;
		protected var parameterTypes : Array;
		protected var requiredParameters : int = 0;
		
		
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function MethodInjectionPoint(node : XML, injectorMappings : Dictionary)
		{
			super(node, injectorMappings);
		}
		
		override public function applyInjection(
			target : Object, injector : Injector, singletons : Dictionary) : Object
		{
			var parameters : Array = gatherParameterValues(target, injector, singletons);
			var method : Function = target[methodName];
			method.apply(target, parameters);
			return target;
		}


		/*******************************************************************************************
		*								protected methods										   *
		*******************************************************************************************/
		override protected function initializeInjection(node : XML, injectorMappings : Dictionary) : void
		{
			var nameArgs : XMLList = node.arg.(@key == 'name');
			var methodNode : XML = node.parent();
			
			methodName = methodNode.@name.toString();
			mappings = [];
			parameterTypes = [];
			
			gatherParameters(methodNode, nameArgs, injectorMappings);
		}
		
		protected function gatherParameters(
			methodNode : XML, nameArgs : XMLList, injectorMappings : Dictionary) : void
		{
			var i : int = 0;
			for each (var parameter : XML in methodNode.parameter)
			{
				var parameterMappings : Dictionary;
				var injectionName : String;
				if (nameArgs[i])
				{
					injectionName = nameArgs[i].@value.toString();
				}
				if (injectionName)
				{
					parameterMappings = injectorMappings[injectionName];
					if (!parameterMappings)
					{
						parameterMappings = injectorMappings[injectionName] = new Dictionary();
					}
				}
				else
				{
					parameterMappings = injectorMappings;
				}
				mappings.push(parameterMappings);
				parameterTypes.push(parameter.@type.toString());
				if (parameter.@optional.toString() == 'false')
				{
					requiredParameters++;
				}
				i++;
			}
		}
		
		protected function gatherParameterValues(
			target : Object, injector : Injector, singletons : Dictionary) : Array
		{
			var parameters : Array = [];
			var length : int = mappings.length;
			for (var i : int = 0; i < length; i++)
			{
				var config : InjectionConfig = mappings[i][parameterTypes[i]];
				if (!config)
				{
					if (i >= requiredParameters)
					{
						break;
					}
					throw(new InjectorError(
						'Injector is missing a rule to handle injection into target ' + target + 
						'. Target dependency: ' + parameterTypes[i] + ', method: ' + methodName + 
						', parameter: ' + (i + 1)
					));
				}
				
				var injection : Object = config.getResponse(injector, singletons);
				parameters[i] = injection;
			}
			return parameters;
		}
	}
}