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

package org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.InjectorError;
	
	public class ConstructorInjectionPoint extends MethodInjectionPoint
	{
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function ConstructorInjectionPoint(node : XML, injectorMappings : Dictionary, clazz : Class)
		{
			/*
			  In many cases, the flash player doesn't give us type information for constructors until 
			  the class has been instantiated at least once. Therefore, we do just that if we don't get 
			  type information for at least one parameter.
			 */ 
			if (node.parameter.(@type == '*').length() == node.parameter.@type.length())
			{
				node = createDummyInstance(node, clazz);
			}
			super(node, injectorMappings);
		}
		
		override public function applyInjection(
			target : Object, injector : Injector, singletons : Dictionary) : Object
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
				
				var injection : Object = config.getResponse(injector, singletons);
				parameters[i] = injection;
			}
			var p : Array = parameters;
			//the only way to implement ctor injections, really!
			switch (p.length)
			{
				case 0 : return (new target());
				case 1 : return (new target(p[0]));
				case 2 : return (new target(p[0], p[1]));
				case 3 : return (new target(p[0], p[1], p[2]));
				case 4 : return (new target(p[0], p[1], p[2], p[3]));
				case 5 : return (new target(p[0], p[1], p[2], p[3], p[4]));
				case 6 : return (new target(p[0], p[1], p[2], p[3], p[4], p[5]));
				case 7 : return (new target(p[0], p[1], p[2], p[3], p[4], p[5], p[6]));
				case 8 : return (new target(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]));
				case 9 : return (new target(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]));
				case 10 : return (new target(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]));
			}
			return null;
		}

		/*******************************************************************************************
		*								protected methods										   *
		*******************************************************************************************/
		override protected function initializeInjection(node : XML, injectorMappings : Dictionary) : void
		{
			var nameArgs : XMLList = node.parent().metadata.(@name == 'Inject').arg.(@key == 'name');
			mappings = [];
			parameterTypes = [];
			
			gatherParameters(node, nameArgs, injectorMappings);
		}
		
		/*******************************************************************************************
		*								private methods											   *
		*******************************************************************************************/
		private function createDummyInstance(constructorNode : XML, clazz : Class) : XML
		{
			try
			{
				switch (constructorNode.children().length())
				{
					case 0 : (new clazz()); break;
					case 1 : (new clazz(null)); break;
					case 2 : (new clazz(null, null)); break;
					case 3 : (new clazz(null, null, null)); break;
					case 4 : (new clazz(null, null, null, null)); break;
					case 5 : (new clazz(null, null, null, null, null)); break;
					case 6 : (new clazz(null, null, null, null, null, null)); break;
					case 7 : (new clazz(null, null, null, null, null, null, null)); break;
					case 8 : (new clazz(null, null, null, null, null, null, null, null)); break;
					case 9 : (new clazz(null, null, null, null, null, null, null, null, null)); break;
					case 10 : (new clazz(null, null, null, null, null, null, null, null, null, null)); break;
				}
			}
			catch (error : Error)
			{
				trace(error);
			}
			return describeType(clazz).factory.constructor[0];
		}
	}
}