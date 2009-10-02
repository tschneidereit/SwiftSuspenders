/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package org.swiftsuspenders
{
	import flash.utils.Dictionary;

	public class MethodInjectionPoint extends InjectionPoint
	{
		/*******************************************************************************************
		*								private properties										   *
		*******************************************************************************************/
		private var methodName : String;
		private var mappings : Array;
		private var parameterTypes : Array;
		
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function MethodInjectionPoint(node : XML, injectorMappings : Dictionary)
		{
			super(node, injectorMappings);
		}
		
		override public function applyInjection(
			target : Object, injector : Injector, singletons : Dictionary) : void
		{
			var parameters : Array = [];
			var length : int = mappings.length;
			for (var i : int = 0; i < length; i++)
			{
				var config : InjectionConfig = mappings[i][parameterTypes[i]];
				if (!config)
				{
					throw(new InjectorError(
						'Injector is missing a rule to handle injection into target ' + target + 
						'. Target dependency: ' + parameterTypes[i] + ', method: ' + methodName + 
						', parameter: ' + (i + 1)
					));
				}
				
				var injection : Object = config.getResponse(target, injector, singletons);
				parameters[i] = injection;
			}
			var method : Function = target[methodName];
			method.apply(target, parameters);
		}

		override protected function initializeInjection(node : XML, injectorMappings : Dictionary) : void
		{
			var nameArgs : XMLList = node.arg.(@key == 'name');
			var methodNode : XML = node.parent();
			
			methodName = methodNode.@name.toString();
			mappings = [];
			parameterTypes = [];
			
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
				i++;
			}
		}
	}
}