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
	import org.swiftsuspenders.injectionpoints.MethodInjectionPoint;
	import org.swiftsuspenders.injectionpoints.NoParamsConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.PostConstructInjectionPoint;
	import org.swiftsuspenders.injectionpoints.PreDestroyInjectionPoint;
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
				return _traits.bases.length > 0 ? new NoParamsConstructorInjectionPoint() : null;
			}
			const injectParameters : Object =
					_traits.metadata && extractTagParameters('Inject', _traits.metadata);
			const parameterNames : Array =
				(injectParameters && injectParameters.name || '').split(',');
			const requiredParameters : int = gatherMethodParameters(parameters, parameterNames);
			return new ConstructorInjectionPoint(parameters, requiredParameters);
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
				var injectParameters : Object =
						method.metadata && extractTagParameters('Inject', method.metadata);
				if (!injectParameters)
				{
					continue;
				}
				var optional : Boolean = injectParameters.optional
					&& (injectParameters.optional == 'true' || injectParameters.optional == '1');
				var parameterNames : Array = (injectParameters.name || '').split(',');
				var parameters : Array = method.parameters;
				const requiredParameters : uint =
						gatherMethodParameters(parameters, parameterNames);
				var injectionPoint : MethodInjectionPoint = new MethodInjectionPoint(
						method.name, parameters, requiredParameters, optional);
				lastInjectionPoint.next = injectionPoint;
				lastInjectionPoint = injectionPoint;
			}
			return lastInjectionPoint;
		}

		public function addPostConstructMethodPointsToList(
				lastInjectionPoint : InjectionPoint) : InjectionPoint
		{
			return gatherOrderedInjectionPointsForTag(lastInjectionPoint,
				PostConstructInjectionPoint, 'PostConstruct');
		}

		public function addPreDestroyMethodPointsToList(
			lastInjectionPoint : InjectionPoint) : InjectionPoint
		{
			return gatherOrderedInjectionPointsForTag(lastInjectionPoint,
				PreDestroyInjectionPoint, 'PreDestroy');
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
				var injectParameters : Object =
						field.metadata && extractTagParameters('Inject', field.metadata);
				if (!injectParameters)
				{
					continue;
				}
				var mappingName : String = injectParameters.name || '';
				var optional : Boolean = injectParameters.optional
					&& (injectParameters.optional == 'true' || injectParameters.optional == '1');
				var injectionPoint : PropertyInjectionPoint = new PropertyInjectionPoint(
						field.type + '|' + mappingName, field.name, optional);
				lastInjectionPoint.next = injectionPoint;
				lastInjectionPoint = injectionPoint;
			}
			return lastInjectionPoint;
		}

		private function gatherMethodParameters(parameters : Array, parameterNames : Array) : uint
		{
			var requiredLength : uint = 0;
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
				if (!parameter.optional)
				{
					requiredLength++;
				}
				parameters[i] = parameterTypeName + '|' + injectionName;
			}
			return requiredLength;
		}

		private function gatherOrderedInjectionPointsForTag(lastInjectionPoint : InjectionPoint,
				injectionPointClass : Class, tag : String) : InjectionPoint
		{
			const injectionPoints : Array = [];
			const methods : Array = _traits.methods;
			if (!methods)
			{
				return lastInjectionPoint;
			}
			var length : uint = methods.length;
			for (var i : int = 0; i < length; i++)
			{
				var method : Object = methods[i];
				var postConstructParameters : Object =
					method.metadata && extractTagParameters(tag, method.metadata);
				if (!postConstructParameters)
				{
					continue;
				}
				var order : int = parseInt(postConstructParameters.order, 10);
				if (order != postConstructParameters.order)
				{
					order = int.MAX_VALUE;
				}
				injectionPoints.push(new injectionPointClass(method.name, order));
			}
			if (injectionPoints.length > 0)
			{
				injectionPoints.sortOn('order', Array.NUMERIC);
				length = injectionPoints.length;
				for (i = 0; i < length; i++)
				{
					var injectionPoint : InjectionPoint = injectionPoints[i];
					lastInjectionPoint.next = injectionPoint;
					lastInjectionPoint = injectionPoint;
				}
			}
			return lastInjectionPoint;
		}

		private function extractTagParameters(tag : String, metadata : Array) : Object
		{
			var length : uint = metadata.length;
			for (var i : int = 0; i < length; i++)
			{
				var entry : Object = metadata[i];
				if (entry.name == tag)
				{
					const parametersList : Array = entry.value;
					const parametersMap : Object = {};
					const parametersCount : int = parametersList.length;
					for (var j : int = 0; j < parametersCount; j++)
					{
						const parameter : Object = parametersList[j];
						parametersMap[parameter.key] = parametersMap[parameter.key]
							? parametersMap[parameter.key] + ',' + parameter.value
							: parameter.value;
					}
					return parametersMap;
				}
			}
			return null;
		}
	}
}