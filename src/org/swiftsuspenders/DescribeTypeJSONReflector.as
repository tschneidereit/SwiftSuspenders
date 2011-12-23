/*
 * Copyright (c) 2011 the original author or authors
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

	import org.swiftsuspenders.typedescriptions.ConstructorInjectionPoint;
	import org.swiftsuspenders.typedescriptions.InjectionPoint;
	import org.swiftsuspenders.typedescriptions.MethodInjectionPoint;
	import org.swiftsuspenders.typedescriptions.NoParamsConstructorInjectionPoint;
	import org.swiftsuspenders.typedescriptions.PostConstructInjectionPoint;
	import org.swiftsuspenders.typedescriptions.PreDestroyInjectionPoint;
	import org.swiftsuspenders.typedescriptions.PropertyInjectionPoint;
	import org.swiftsuspenders.typedescriptions.TypeDescription;

	public class DescribeTypeJSONReflector extends ReflectorBase implements Reflector
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _descriptor : DescribeTypeJSON;
		private var _rawDescription : Object;
		private var _traits : Object;

		//----------------------               Public Methods               ----------------------//
		public function DescribeTypeJSONReflector()
		{
			_descriptor = new DescribeTypeJSON();
		}

		public function typeImplements(type : Class, superType : Class) : Boolean
		{
			if (type == superType)
			{
				return true;
			}
			const superClassName : String = getQualifiedClassName(superType);

			const traits : Object = _descriptor.getInstanceDescription(type).traits;
			return (traits.bases as Array).indexOf(superClassName) > -1
					|| (traits.interfaces as Array).indexOf(superClassName) > -1;
		}

		public function describeInjections(type : Class) : TypeDescription
		{
			_rawDescription = _descriptor.getInstanceDescription(type);
			_traits = _rawDescription.traits;
			const description : TypeDescription = new TypeDescription();
			addCtorInjectionPoint(description);
			addFieldInjectionPoints(description, _traits.variables);
			addFieldInjectionPoints(description, _traits.accessors);
			addMethodInjectionPoints(description);
			addPostConstructMethodPoints(description);
			addPreDestroyMethodPoints(description);
			_rawDescription = null;
			_traits = null;
			return description;
		}

		//----------------------         Private / Protected Methods        ----------------------//
		private function addCtorInjectionPoint(description : TypeDescription) : void
		{
			const parameters : Array = _traits.constructor;
			if (!parameters)
			{
				description.ctor =  _traits.bases.length > 0
					? new NoParamsConstructorInjectionPoint()
					: null;
				return;
			}
			const injectParameters : Object =
					_traits.metadata && extractTagParameters('Inject', _traits.metadata);
			const parameterNames : Array =
				(injectParameters && injectParameters.name || '').split(',');
			const requiredParameters : int = gatherMethodParameters(parameters, parameterNames);
			description.ctor = new ConstructorInjectionPoint(parameters, requiredParameters);
		}

		private function addMethodInjectionPoints(description : TypeDescription) : void
		{
			const methods : Array = _traits.methods;
			if (!methods)
			{
				return;
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
				var optional : Boolean = injectParameters.optional == 'true';
				var parameterNames : Array = (injectParameters.name || '').split(',');
				var parameters : Array = method.parameters;
				const requiredParameters : uint =
						gatherMethodParameters(parameters, parameterNames);
				var injectionPoint : MethodInjectionPoint = new MethodInjectionPoint(
						method.name, parameters, requiredParameters, optional);
				description.addInjectionPoint(injectionPoint);
			}
		}

		private function addPostConstructMethodPoints(description : TypeDescription) : void
		{
			var injectionPoints : Array = gatherOrderedInjectionPointsForTag(
				PostConstructInjectionPoint, 'PostConstruct');
			for (var i : int = 0, length : int = injectionPoints.length; i < length; i++)
			{
				description.addInjectionPoint(injectionPoints[i]);
			}
		}

		private function addPreDestroyMethodPoints(description : TypeDescription) : void
		{
			var injectionPoints : Array = gatherOrderedInjectionPointsForTag(
				PreDestroyInjectionPoint, 'PreDestroy');
			if (!injectionPoints.length)
			{
				return;
			}
			description.preDestroyMethods = injectionPoints[0];
			description.preDestroyMethods.last = injectionPoints[0];
			for (var i : int = 1, length : int = injectionPoints.length; i < length; i++)
			{
				description.preDestroyMethods.last.next = injectionPoints[i];
				description.preDestroyMethods.last = injectionPoints[i];
			}
		}

		private function addFieldInjectionPoints(
			description : TypeDescription, fields : Array) : void
		{
			if (!fields)
			{
				return;
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
				var optional : Boolean = injectParameters.optional == 'true';
				var injectionPoint : PropertyInjectionPoint = new PropertyInjectionPoint(
						field.type + '|' + mappingName, field.name, optional);
				description.addInjectionPoint(injectionPoint);
			}
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
								_rawDescription.name + '. Required parameters can\'t have type "*".');
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

		private function gatherOrderedInjectionPointsForTag(
				injectionPointClass : Class, tag : String) : Array
		{
			const injectionPoints : Array = [];
			const methods : Array = _traits.methods;
			if (!methods)
			{
				return injectionPoints;
			}
			var length : uint = methods.length;
			for (var i : int = 0; i < length; i++)
			{
				var method : Object = methods[i];
				var parameters : Object =
					method.metadata && extractTagParameters(tag, method.metadata);
				if (!parameters)
				{
					continue;
				}
				var order : int = parseInt(parameters.order, 10);
				//int can't be NaN, so we have to verify that parsing succeeded by comparison
				if (order.toString(10) != parameters.order)
				{
					order = int.MAX_VALUE;
				}
				injectionPoints.push(new injectionPointClass(method.name, order));
			}
			if (injectionPoints.length > 0)
			{
				injectionPoints.sortOn('order', Array.NUMERIC);
			}
			return injectionPoints;
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