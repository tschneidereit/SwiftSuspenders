/*
 * Copyright (c) 2009-2011 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.swiftsuspenders.injectionpoints.ConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPoint;
	import org.swiftsuspenders.injectionpoints.MethodInjectionPoint;
	import org.swiftsuspenders.injectionpoints.NoParamsConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.PostConstructInjectionPoint;
	import org.swiftsuspenders.injectionpoints.PropertyInjectionPoint;
	import org.swiftsuspenders.dependencyproviders.ClassProvider;
	import org.swiftsuspenders.dependencyproviders.OtherRuleProvider;
	import org.swiftsuspenders.dependencyproviders.SingletonProvider;
	import org.swiftsuspenders.dependencyproviders.ValueProvider;

	public class Injector
	{
		/*******************************************************************************************
		*								private properties										   *
		*******************************************************************************************/
		private static var INJECTION_POINTS_CACHE : Dictionary = new Dictionary(true);
		private var _parentInjector : Injector;
        private var _applicationDomain:ApplicationDomain;
		private var _mappings : Dictionary;
		private var _injecteeDescriptions : Dictionary;
		private var _attendedToInjectees : Dictionary;
		private var _xmlMetadata : XML;
		
		
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function Injector(xmlConfig : XML = null)
		{
			_mappings = new Dictionary();
			if (xmlConfig != null)
			{
				_injecteeDescriptions = new Dictionary(true);
			}
			else
			{
				_injecteeDescriptions = INJECTION_POINTS_CACHE;
			}
			_attendedToInjectees = new Dictionary(true);
			_xmlMetadata = xmlConfig;
		}

		public function map(type : Class) : InjectionRule
		{
			return getMapping(type) || createRule(type);
		}

		public function mapNamed(type : Class, name : String) : InjectionRule
		{
			return getMapping(type, name) || createRule(type, name);
		}
		
		public function mapSingleton(whenAskedFor : Class, named : String = "") : *
		{
			return mapSingletonOf(whenAskedFor, whenAskedFor, named);
		}
		
		public function mapSingletonOf(
			whenAskedFor : Class, useSingletonOf : Class, named : String = "") : *
		{
			var config : InjectionRule = getMapping(whenAskedFor, named) || createRule(whenAskedFor);
			config.setProvider(new SingletonProvider(useSingletonOf));
			return config;
		}
		
		public function mapRule(whenAskedFor : Class, useRule : *, named : String = "") : *
		{
			var config : InjectionRule = getMapping(whenAskedFor, named) || createRule(whenAskedFor);
			config.setProvider(new OtherRuleProvider(useRule));
			return useRule;
		}
		
		public function getMapping(requestType : Class, named : String = "") : InjectionRule
		{
			return _mappings[getQualifiedClassName(requestType) + named] || createRule(requestType, named);
		}
		
		public function injectInto(target : Object) : void
		{
			if (_attendedToInjectees[target])
			{
				return;
			}
			_attendedToInjectees[target] = true;

			//get injection points or cache them if this target's class wasn't encountered before
			var targetClass : Class = getConstructor(target);
			var injecteeDescription : InjecteeDescription =
					_injecteeDescriptions[targetClass] || getInjectionPoints(targetClass);

			var injectionPoints : Array = injecteeDescription.injectionPoints;
			var length : int = injectionPoints.length;
			for (var i : int = 0; i < length; i++)
			{
				var injectionPoint : InjectionPoint = injectionPoints[i];
				injectionPoint.applyInjection(target, this);
			}

		}
		
		public function instantiate(clazz:Class):*
		{
			var injecteeDescription : InjecteeDescription = _injecteeDescriptions[clazz];
			if (!injecteeDescription)
			{
				injecteeDescription = getInjectionPoints(clazz);
			}
			var injectionPoint : InjectionPoint = injecteeDescription.ctor;
			var instance : * = injectionPoint.applyInjection(clazz, this);
			injectInto(instance);
			return instance;
		}
		
		public function unmap(clazz : Class, named : String = "") : void
		{
			var mapping : InjectionRule = getConfigurationForRequest(clazz, named);
			if (!mapping)
			{
				throw new InjectorError('Error while removing an injector mapping: ' +
					'No mapping defined for class ' + getQualifiedClassName(clazz) +
					', named "' + named + '"');
			}
			mapping.setProvider(null);
		}

		public function hasMapping(clazz : Class, named : String = '') : Boolean
		{
			var mapping : InjectionRule = getConfigurationForRequest(clazz, named);
			if (!mapping)
			{
				return false;
			}
			return mapping.hasProvider(this);
		}

		public function getInstance(clazz : Class, named : String = '') : *
		{
			var mapping : InjectionRule = getConfigurationForRequest(clazz, named);
			if (!mapping || !mapping.hasProvider(this))
			{
				throw new InjectorError('Error while getting mapping response: ' +
					'No mapping defined for class ' + getQualifiedClassName(clazz) +
					', named "' + named + '"');
			}
			return mapping.apply(this);
		}
		
		public function createChildInjector(applicationDomain:ApplicationDomain=null) : Injector
		{
			var injector : Injector = new Injector();
            injector.setApplicationDomain(applicationDomain);
			injector.setParentInjector(this);
			return injector;
		}
        
        public function setApplicationDomain(applicationDomain:ApplicationDomain):void
        {
            _applicationDomain = applicationDomain;
        }
        
        public function getApplicationDomain():ApplicationDomain
        {
            return _applicationDomain ? _applicationDomain : ApplicationDomain.currentDomain;
        }

		public function setParentInjector(parentInjector : Injector) : void
		{
			//restore own map of worked injectees if parent injector is removed
			if (_parentInjector && !parentInjector)
			{
				_attendedToInjectees = new Dictionary(true);
			}
			_parentInjector = parentInjector;
			//use parent's map of worked injectees
			if (parentInjector)
			{
				_attendedToInjectees = parentInjector.attendedToInjectees;
			}
		}
		
		public function getParentInjector() : Injector
		{
			return _parentInjector;
		}

		public static function purgeInjectionPointsCache() : void
		{
			INJECTION_POINTS_CACHE = new Dictionary(true);
		}
		
		
		/*******************************************************************************************
		*								internal methods										   *
		*******************************************************************************************/
		internal function getAncestorMapping(
				whenAskedFor : Class, named : String = null) : InjectionRule
		{
			var parent : Injector = _parentInjector;
			while (parent)
			{
				var parentConfig : InjectionRule =
					parent.getConfigurationForRequest(whenAskedFor, named, false);
				if (parentConfig && parentConfig.hasOwnProvider())
				{
					return parentConfig;
				}
				parent = parent.getParentInjector();
			}
			return null;
		}

		internal function get attendedToInjectees() : Dictionary
		{
			return _attendedToInjectees;
		}

		
		/*******************************************************************************************
		*								private methods											   *
		*******************************************************************************************/
		private function createRule(requestType : Class, name : String = '') : InjectionRule
		{
			//TODO: check if it's ok to use the Class itself as the key here
			return (_mappings[getQualifiedClassName(requestType) + name] =
					new InjectionRule(requestType, ''));
		}

		private function getInjectionPoints(clazz : Class) : InjecteeDescription
		{
			var description : XML = describeType(clazz);
			if (description.@name != 'Object' && description.factory.extendsClass.length() == 0)
			{
				throw new InjectorError('Interfaces can\'t be used as instantiatable classes.');
			}
			var injectionPoints : Array = [];
			var node : XML;
			
			// This is where we have to wire in the XML...
			if(_xmlMetadata)
			{
				createInjectionPointsFromConfigXML(description);
				addParentInjectionPoints(description, injectionPoints);
			}

			//get constructor injections
			var ctorInjectionPoint : InjectionPoint;
			node = description.factory.constructor[0];
			if (node)
			{
				ctorInjectionPoint = new ConstructorInjectionPoint(node, clazz);
			}
			else
			{
				ctorInjectionPoint = new NoParamsConstructorInjectionPoint();
			}
			var injectionPoint : InjectionPoint;
			//get injection points for variables
			for each (node in description.factory.*.
				(name() == 'variable' || name() == 'accessor').metadata.(@name == 'Inject'))
			{
				injectionPoint = new PropertyInjectionPoint(node);
				injectionPoints.push(injectionPoint);
			}
		
			//get injection points for methods
			for each (node in description.factory.method.metadata.(@name == 'Inject'))
			{
				injectionPoint = new MethodInjectionPoint(node);
				injectionPoints.push(injectionPoint);
			}
			
			//get post construct methods
			var postConstructMethodPoints : Array = [];
			for each (node in description.factory.method.metadata.(@name == 'PostConstruct'))
			{
				injectionPoint = new PostConstructInjectionPoint(node);
				postConstructMethodPoints.push(injectionPoint);
			}
			if (postConstructMethodPoints.length > 0)
			{
				postConstructMethodPoints.sortOn("order", Array.NUMERIC);
				injectionPoints.push.apply(injectionPoints, postConstructMethodPoints);
			}

			var injecteeDescription : InjecteeDescription =
					new InjecteeDescription(ctorInjectionPoint, injectionPoints);
			_injecteeDescriptions[clazz] = injecteeDescription;
			return injecteeDescription;
		}

		private function getConfigurationForRequest(
			clazz : Class, named : String, traverseAncestors : Boolean = true) : InjectionRule
		{
			var requestName : String = getQualifiedClassName(clazz);
			var config:InjectionRule = _mappings[requestName + named];
			if(!config && traverseAncestors &&
				_parentInjector && _parentInjector.hasMapping(clazz, named))
			{
				config = getAncestorMapping(clazz, named);
			}
			return config;
		}
		
		private function createInjectionPointsFromConfigXML(description : XML) : void
		{
			var node : XML;
			//first, clear out all "Inject" metadata, we want a clean slate to have the result 
			//work the same in the Flash IDE and MXMLC
			for each (node in description..metadata.(@name=='Inject' || @name=='PostConstruct'))
			{
				delete node.parent().metadata.(@name=='Inject' || @name=='PostConstruct')[0];
			}
			
			//now, we create the new injection points based on the given xml file
			var className:String = description.factory.@type;
			for each (node in _xmlMetadata.type.(@name == className).children())
			{
				var metaNode : XML = <metadata/>;
				if (node.name() == 'postconstruct')
				{
					metaNode.@name = 'PostConstruct';
					if (node.@order.length())
					{
						metaNode.appendChild(<arg key='order' value={node.@order}/>);
					}
				}
				else
				{
					metaNode.@name = 'Inject';
					if (node.@injectionname.length())
					{
						metaNode.appendChild(<arg key='name' value={node.@injectionname}/>);
					}
					for each (var arg : XML in node.arg)
					{
						metaNode.appendChild(<arg key='name' value={arg.@injectionname}/>);
					}
				}
				var typeNode : XML;
				if (node.name() == 'constructor')
				{
					typeNode = description.factory[0];
				}
				else
				{
					typeNode = description.factory.*.(attribute('name') == node.@name)[0];
					if (!typeNode)
					{
						throw new InjectorError('Error in XML configuration: Class "' + className +
							'" doesn\'t contain the instance member "' + node.@name + '"');
					}
				}
				typeNode.appendChild(metaNode);
			}
		}
		
		private function addParentInjectionPoints(description : XML, injectionPoints : Array) : void
		{
			var parentClassName : String = description.factory.extendsClass.@type[0];
			if (!parentClassName)
			{
				return;
			}
			var parentClass : Class = Class(getDefinitionByName(parentClassName));
			var parentDescription : InjecteeDescription =
					_injecteeDescriptions[parentClass] || getInjectionPoints(parentClass);
			var parentInjectionPoints : Array = parentDescription.injectionPoints;

			injectionPoints.push.apply(injectionPoints, parentInjectionPoints);
		}
	}
}

import org.swiftsuspenders.injectionpoints.InjectionPoint;

final class InjecteeDescription
{
	public var ctor : InjectionPoint;
	public var injectionPoints : Array;

	public function InjecteeDescription(ctor : InjectionPoint, injectionPoints : Array)
	{
		this.ctor = ctor;
		this.injectionPoints = injectionPoints;
	}
}