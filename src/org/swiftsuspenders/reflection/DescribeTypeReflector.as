/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.reflection
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.errors.InjectorError;

	import org.swiftsuspenders.typedescriptions.ConstructorInjectionPoint;
	import org.swiftsuspenders.typedescriptions.MethodInjectionPoint;
	import org.swiftsuspenders.typedescriptions.NoParamsConstructorInjectionPoint;
	import org.swiftsuspenders.typedescriptions.PostConstructInjectionPoint;
	import org.swiftsuspenders.typedescriptions.PreDestroyInjectionPoint;
	import org.swiftsuspenders.typedescriptions.PropertyInjectionPoint;
	import org.swiftsuspenders.typedescriptions.TypeDescription;

	public class DescribeTypeReflector extends ReflectorBase implements Reflector
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _currentFactoryXML : XML;

		//----------------------               Public Methods               ----------------------//
		public function typeImplements(type : Class, superType : Class) : Boolean
		{
            if (type == superType)
            {
	            return true;
            }

            var factoryDescription : XML = describeType(type).factory[0];

			return (factoryDescription.children().(
            	name() == "implementsInterface" || name() == "extendsClass").(
            	attribute("type") == getQualifiedClassName(superType)).length() > 0);
		}

		public function describeInjections(type : Class) : TypeDescription
		{
			_currentFactoryXML = describeType(type).factory[0];
			const description : TypeDescription = new TypeDescription(false);
			addCtorInjectionPoint(description, type);
			addFieldInjectionPoints(description);
			addMethodInjectionPoints(description);
			addPostConstructMethodPoints(description);
			addPreDestroyMethodPoints(description);
			_currentFactoryXML = null;
			return description;
		}

		//----------------------         Private / Protected Methods        ----------------------//
		private function addCtorInjectionPoint(description : TypeDescription, type : Class) : void
		{
			const node : XML = _currentFactoryXML.constructor[0];
			if (!node)
			{
				if (_currentFactoryXML.parent().@name == 'Object'
						|| _currentFactoryXML.extendsClass.length() > 0)
				{
					description.ctor = new NoParamsConstructorInjectionPoint();
				}
				return;
			}
			const injectParameters : Dictionary = extractNodeParameters(node.parent().metadata.arg);
			const parameterNames : Array = (injectParameters.name || '').split(',');
			const parameterNodes : XMLList = node.parameter;
			/*
			 In many cases, the flash player doesn't give us type information for constructors until
			 the class has been instantiated at least once. Therefore, we do just that if we don't get
			 type information for at least one parameter.
			 */
			if (parameterNodes.(@type == '*').length() == parameterNodes.@type.length())
			{
				createDummyInstance(node, type);
			}
			const parameters : Array = gatherMethodParameters(parameterNodes, parameterNames);
			const requiredParameters : uint = parameters.required;
			delete parameters.required;
			description.ctor = new ConstructorInjectionPoint(parameters, requiredParameters,
				injectParameters);
		}
		private function extractNodeParameters(args : XMLList) : Dictionary
		{
			const parametersMap : Dictionary = new Dictionary();
			var length : uint = args.length();
			for (var i : int = 0; i < length; i++)
			{
				var parameter : XML = args[i];
				var key : String = parameter.@key;
				parametersMap[key] = parametersMap[key]
					? parametersMap[key] + ',' + parameter.attribute('value')
					: parameter.attribute('value');
			}
			return parametersMap;
		}
		private function addFieldInjectionPoints(description : TypeDescription) : void
		{
			for each (var node : XML in _currentFactoryXML.*.
					(name() == 'variable' || name() == 'accessor').metadata.(@name == 'Inject'))
			{
				var mappingId : String =
						node.parent().@type + '|' + node.arg.(@key == 'name').attribute('value');
				var propertyName : String = node.parent().@name;
				const injectParameters : Dictionary = extractNodeParameters(node.arg);
				var injectionPoint : PropertyInjectionPoint = new PropertyInjectionPoint(mappingId,
					propertyName, injectParameters.optional == 'true', injectParameters);
				description.addInjectionPoint(injectionPoint);
			}
		}

		private function addMethodInjectionPoints(description : TypeDescription) : void
		{
			for each (var node : XML in _currentFactoryXML.method.metadata.(@name == 'Inject'))
			{
				const injectParameters : Dictionary = extractNodeParameters(node.arg);
				const parameterNames : Array = (injectParameters.name || '').split(',');
				const parameters : Array =
						gatherMethodParameters(node.parent().parameter, parameterNames);
				const requiredParameters : uint = parameters.required;
				delete parameters.required;
				var injectionPoint : MethodInjectionPoint = new MethodInjectionPoint(
					node.parent().@name, parameters, requiredParameters,
					injectParameters.optional == 'true', injectParameters);
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

		private function gatherMethodParameters(
			parameterNodes : XMLList, parameterNames : Array) : Array
		{
			var requiredParameters : uint = 0;
			const length : uint = parameterNodes.length();
			const parameters : Array = new Array(length);
			for (var i : int = 0; i < length; i++)
			{
				var parameter : XML = parameterNodes[i];
				var injectionName : String = parameterNames[i] || '';
				var parameterTypeName : String = parameter.@type;
				var optional : Boolean = parameter.@optional == 'true';
				if (parameterTypeName == '*')
				{
					if (!optional)
					{
						throw new InjectorError('Error in method definition of injectee "' +
							_currentFactoryXML.@type + 'Required parameters can\'t have type "*".');
					}
					else
					{
						parameterTypeName = null;
					}
				}
				if (!optional)
				{
					requiredParameters++;
				}
				parameters[i] = parameterTypeName + '|' + injectionName;
			}
			parameters.required = requiredParameters;
			return parameters;
		}

		private function gatherOrderedInjectionPointsForTag(
				injectionPointType : Class, tag : String) : Array
		{
			const injectionPoints : Array = [];
			for each (var node : XML in
				_currentFactoryXML..metadata.(@name == tag))
			{
				const injectParameters : Dictionary = extractNodeParameters(node.arg);
				const parameterNames : Array = (injectParameters.name || '').split(',');
				const parameters : Array =
					gatherMethodParameters(node.parent().parameter, parameterNames);
				const requiredParameters : uint = parameters.required;
				delete parameters.required;
				var order : Number = parseInt(node.arg.(@key == 'order').@value);
				injectionPoints.push(new injectionPointType(node.parent().@name,
					parameters, requiredParameters, isNaN(order) ? int.MAX_VALUE : order));
			}
			if (injectionPoints.length > 0)
			{
				injectionPoints.sortOn('order', Array.NUMERIC);
			}
			return injectionPoints;
		}

		private function createDummyInstance(constructorNode : XML, clazz : Class) : void
		{
			try
			{
				switch (constructorNode.children().length())
				{
					case 0 :(new clazz());break;
					case 1 :(new clazz(null));break;
					case 2 :(new clazz(null, null));break;
					case 3 :(new clazz(null, null, null));break;
					case 4 :(new clazz(null, null, null, null));break;
					case 5 :(new clazz(null, null, null, null, null));break;
					case 6 :(new clazz(null, null, null, null, null, null));break;
					case 7 :(new clazz(null, null, null, null, null, null, null));break;
					case 8 :(new clazz(null, null, null, null, null, null, null, null));break;
					case 9 :(new clazz(null, null, null, null, null, null, null, null, null));break;
					case 10 :
						(new clazz(null, null, null, null, null, null, null, null, null, null));
						break;
				}
			}
			catch (error : Error)
			{
				trace('Exception caught while trying to create dummy instance for constructor ' +
						'injection. It\'s almost certainly ok to ignore this exception, but you ' +
						'might want to restructure your constructor to prevent errors from ' +
						'happening. See the Swiftsuspenders documentation for more details.\n' +
						'The caught exception was:\n' + error);
			}
			constructorNode.setChildren(describeType(clazz).factory.constructor[0].children());
		}
	}
}