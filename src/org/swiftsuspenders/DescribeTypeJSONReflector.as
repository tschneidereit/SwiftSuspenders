/*
 * Copyright (c) 2009-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import avmplus.DescribeTypeJSON;

	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.injectionpoints.ConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPointConfig;
	import org.swiftsuspenders.injectionpoints.MethodInjectionPoint;
	import org.swiftsuspenders.injectionpoints.NoParamsConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.PostConstructInjectionPoint;
	import org.swiftsuspenders.injectionpoints.PropertyInjectionPoint;

	public class DescribeTypeJSONReflector extends ReflectorBase implements Reflector
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _currentType : Class;
		private var _descriptor : DescribeTypeJSON;
		private var _description : Object;
		private var _traits : Object;

		//----------------------               Public Methods               ----------------------//
		public function DescribeTypeJSONReflector()
		{
			_descriptor = new DescribeTypeJSON();
		}

		public function startReflection(type : Class) : void
		{
			_currentType = type;
			_description = _descriptor.getInstanceDescription(type);
			_traits = _description.traits;
		}

		public function endReflection() : void
		{
			_currentType = null;
			_description = null;
			_traits = null;
		}

		public function classExtendsOrImplements(classOrClassName : Object, superclass : Class,
		                                         application : ApplicationDomain = null) : Boolean
		{
			var actualClass : Class;

			if (classOrClassName is Class)
			{
				actualClass = Class(classOrClassName);
			}
			else if (classOrClassName is String)
			{
				try
				{
					actualClass = Class(getDefinitionByName(classOrClassName as String));
				}
				catch (e : Error)
				{
					throw new Error("The class name " + classOrClassName +
							" is not valid because of " + e + "\n" + e.getStackTrace());
				}
			}

			if (!actualClass)
			{
				throw new Error("The parameter classOrClassName must be a valid Class " +
						"instance or fully qualified class name.");
			}

			if (actualClass == superclass)
			{
				return true;
			}
			const superClassName : String = getQualifiedClassName(superclass);

			startReflection(actualClass);
			return (_traits.bases as Array).indexOf(superClassName) > -1
					|| (_traits.interfaces as Array).indexOf(superClassName) > -1;
		}

		public function getCtorInjectionPoint() : ConstructorInjectionPoint
		{
			const parameters : Array = _traits.constructor;
			if (!parameters)
			{
				if (_traits.bases.length > 0)
				{
					return new NoParamsConstructorInjectionPoint();
				}
				return null;
			}
			var injectParameters : Array =
					_traits.metadata && extractInjectParameters(_traits.metadata);
			var parameterNames : Array = extractMappingName(injectParameters || []);
			return new ConstructorInjectionPoint(
					gatherMethodParameters(parameters, parameterNames));
		}

		public function addFieldInjectionPointsToList(
				lastInjectionPoint : InjectionPoint) : InjectionPoint
		{
			lastInjectionPoint = gatherFieldInjectionPoints(_traits.accessors, lastInjectionPoint);
			return gatherFieldInjectionPoints(_traits.variables, lastInjectionPoint);
		}

		public function addMethodInjectionPointsToList(
				lastInjectionPoint : InjectionPoint) : InjectionPoint
		{
			const methods : Array = _traits.methods;
			if (!methods)
			{
				return lastInjectionPoint;
			}
			const length : uint = methods.length;
			for (var i : int = 0; i < length; i++)
			{
				var method : Object = methods[i];
				var injectParameters : Array =
						method.metadata && extractInjectParameters(method.metadata);
				if (!injectParameters)
				{
					continue;
				}
				var optional : Boolean = extractOptionalFlag(injectParameters);
				var parameterNames : Array = extractMappingName(injectParameters);
				var parameters : Array = gatherMethodParameters(method.parameters, parameterNames);
				var injectionPoint : MethodInjectionPoint =
						new MethodInjectionPoint(method.name, parameters, optional);
				lastInjectionPoint.next = injectionPoint;
				lastInjectionPoint = injectionPoint;
			}
			return lastInjectionPoint;
		}

		public function addPostConstructMethodPointsToList(
				lastInjectionPoint : InjectionPoint) : InjectionPoint
		{
			const postConstructMethodPoints : Array = [];
			const methods : Array = _traits.methods;
			if (!methods)
			{
				return lastInjectionPoint;
			}
			var length : uint = methods.length;
			for (var i : int = 0; i < length; i++)
			{
				var method : Object = methods[i];
				var postConstructParameters : Array =
						method.metadata && extractPostConstructParameters(method.metadata);
				if (!postConstructParameters)
				{
					continue;
				}
				var order : int = extractOrder(postConstructParameters);
				postConstructMethodPoints.push(new PostConstructInjectionPoint(method.name, order));
			}
			if (postConstructMethodPoints.length > 0)
			{
				postConstructMethodPoints.sortOn('order', Array.NUMERIC);
				length = postConstructMethodPoints.length;
				for (i = 0; i < length; i++)
				{
					var injectionPoint : InjectionPoint = postConstructMethodPoints[i];
					lastInjectionPoint.next = injectionPoint;
					lastInjectionPoint = injectionPoint;
				}
			}
			return lastInjectionPoint;
		}

		
		//----------------------         Private / Protected Methods        ----------------------//
		private function gatherFieldInjectionPoints(
				fields : Array, lastInjectionPoint : InjectionPoint) : InjectionPoint
		{
			if (!fields)
			{
				return lastInjectionPoint;
			}
			const length : uint = fields.length;
			for (var i : int = 0; i < length; i++)
			{
				var field : Object = fields[i];
				var injectParameters : Array =
						field.metadata && extractInjectParameters(field.metadata);
				if (!injectParameters)
				{
					continue;
				}
				var mappingName : String = extractMappingName(injectParameters)[0] || '';
				var optional : Boolean = extractOptionalFlag(injectParameters);
				var config : InjectionPointConfig =
						new InjectionPointConfig(field.type, mappingName, optional);
				var injectionPoint : PropertyInjectionPoint =
						new PropertyInjectionPoint(config, field.name);
				lastInjectionPoint.next = injectionPoint;
				lastInjectionPoint = injectionPoint;
			}
			return lastInjectionPoint;
		}

		private function gatherMethodParameters(parameters : Array, parameterNames : Array) : Array
		{
			const length : uint = parameters.length;
			for (var i : int = 0; i < length; i++)
			{
				var parameter : Object = parameters[i];
				var injectionName : String = parameterNames[i] || '';
				var parameterTypeName : String = parameter.type;
				if (parameterTypeName == '*')
				{
					if (!parameter.optional)
					{
						throw new InjectorError('Error in method definition of injectee "' +
								_description.name + '. Required parameters can\'t have type "*".');
					}
					else
					{
						parameterTypeName = null;
					}
				}
				parameters[i] = new InjectionPointConfig(
						parameterTypeName, injectionName, parameter.optional);
			}
			return parameters;
		}

		private function extractInjectParameters(metadata : Array) : Array
		{
			var length : uint = metadata.length;
			for (var i : int = 0; i < length; i++)
			{
				var entry : Object = metadata[i];
				if (entry.name == 'Inject')
				{
					return entry.value;
				}
			}
			return null;
		}

		private function extractPostConstructParameters(metadata : Array) : Array
		{
			var length : uint = metadata.length;
			for (var i : int = 0; i < length; i++)
			{
				var entry : Object = metadata[i];
				if (entry.name == 'PostConstruct')
				{
					return entry.value;
				}
			}
			return null;
		}

		private function extractOrder(postConstructParameters : Array) : int
		{
			var length : uint = postConstructParameters.length;
			for (var i : int = 0; i < length; i++)
			{
				var parameter : Object = postConstructParameters[i];
				if (parameter.key == 'order')
				{
					const result : Number = parseInt(parameter.value, 10);
					return isNaN(result) ? int.MAX_VALUE : result;
				}
			}
			return int.MAX_VALUE;
		}

		private function extractMappingName(injectParameters : Array) : Array
		{
			var names : Array = [];
			var length : uint = injectParameters.length;
			for (var i : int = 0; i < length; i++)
			{
				var parameter : Object = injectParameters[i];
				if (parameter.key == 'name')
				{
					names.push(parameter.value);
				}
			}
			return names;
		}

		private function extractOptionalFlag(injectParameters : Array) : Boolean
		{
			var length : uint = injectParameters.length;
			for (var i : int = 0; i < length; i++)
			{
				var parameter : Object = injectParameters[i];
				if (parameter.key == 'optional')
				{
					return parameter.value == 'true' || parameter.value == '1';
				}
			}
			return false;
		}
	}
}