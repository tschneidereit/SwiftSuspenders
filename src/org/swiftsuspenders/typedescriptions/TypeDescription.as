/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.typedescriptions
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.errors.InjectorError;

	public class TypeDescription
	{
		//----------------------              Public Properties             ----------------------//
		public var ctor : ConstructorInjectionPoint;
		public var injectionPoints : InjectionPoint;
		public var preDestroyMethods : PreDestroyInjectionPoint;

		//----------------------       Private / Protected Properties       ----------------------//
		private var _postConstructAdded : Boolean;

		//----------------------               Public Methods               ----------------------//
		public function TypeDescription(useDefaultConstructor : Boolean = true)
		{
			if (useDefaultConstructor)
			{
				ctor = new NoParamsConstructorInjectionPoint();
			}
		}

		public function setConstructor(
			parameterTypes : Array, parameterNames : Array = null,
			requiredParameters : uint = int.MAX_VALUE,
			metadata : Dictionary = null) : TypeDescription
		{
			ctor = new ConstructorInjectionPoint(
				createParameterMappings(parameterTypes, parameterNames || []),
				requiredParameters, metadata);
			return this;
		}

		public function addFieldInjection(
			fieldName : String, type : Class, injectionName : String = '',
			optional : Boolean = false, metadata : Dictionary = null) : TypeDescription
		{
			if (_postConstructAdded)
			{
				throw new InjectorError('Can\'t add injection point after post construct method');
			}
			addInjectionPoint(new PropertyInjectionPoint(
				getQualifiedClassName(type) + '|' + injectionName, fieldName, optional, metadata));
			return this;
		}

		public function addMethodInjection(
			methodName : String, parameterTypes : Array, parameterNames : Array = null,
			requiredParameters : uint = int.MAX_VALUE, optional : Boolean = false,
			metadata : Dictionary = null) : TypeDescription
		{
			if (_postConstructAdded)
			{
				throw new InjectorError('Can\'t add injection point after post construct method');
			}
			addInjectionPoint(new MethodInjectionPoint(
				methodName, createParameterMappings(parameterTypes, parameterNames || []),
				Math.min(requiredParameters, parameterTypes.length), optional, metadata));
			return this;
		}

		public function addPostConstructMethod(
			methodName : String, parameterTypes : Array, parameterNames : Array = null,
			requiredParameters : uint = int.MAX_VALUE) : TypeDescription
		{
			_postConstructAdded = true;
			addInjectionPoint(new PostConstructInjectionPoint(
				methodName, createParameterMappings(parameterTypes, parameterNames || []),
				Math.min(requiredParameters, parameterTypes.length), 0));
			return this;
		}

		public function addPreDestroyMethod(
			methodName : String, parameterTypes : Array, parameterNames : Array = null,
			requiredParameters : uint = int.MAX_VALUE) : TypeDescription
		{
			const method : PreDestroyInjectionPoint = new PreDestroyInjectionPoint(
				methodName, createParameterMappings(parameterTypes, parameterNames || []),
				Math.min(requiredParameters, parameterTypes.length), 0);
			if (preDestroyMethods)
			{
				preDestroyMethods.last.next = method;
				preDestroyMethods.last = method;
			}
			else
			{
				preDestroyMethods = method;
				preDestroyMethods.last = method;
			}
			return this;
		}

		public function addInjectionPoint(injectionPoint : InjectionPoint) : void
		{
			if (injectionPoints)
			{
				injectionPoints.last.next = injectionPoint;
				injectionPoints.last = injectionPoint;
			}
			else
			{
				injectionPoints = injectionPoint;
				injectionPoints.last = injectionPoint;
			}
		}

		//----------------------         Private / Protected Methods        ----------------------//
		private function createParameterMappings(
			parameterTypes : Array, parameterNames : Array) : Array
		{
			const parameters : Array = new Array(parameterTypes.length);
			for (var i : int = parameters.length; i--;)
			{
				parameters[i] =
					getQualifiedClassName(parameterTypes[i]) + '|' + (parameterNames[i] || '');
			}
			return parameters;
		}
	}
}