/*
 * Copyright (c) 2009 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
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

	/**
	 * @author tschneidereit
	 */
	public class Injector
	{
		/*******************************************************************************************
		*								protected/ private properties							   *
		*******************************************************************************************/
		private var m_mappings : Dictionary;
		private var m_singletons : Dictionary;
		private var m_injectionPointLists : Dictionary;
		private var m_constructorInjectionPoints : Dictionary;
		private var m_attendedToInjectees : Dictionary;
		private var m_xmlMetadata : XML;
		
		/*******************************************************************************************
		*								public methods											   *
		*******************************************************************************************/
		public function Injector(xmlConfig : XML = null)
		{
			m_mappings = new Dictionary();
			m_singletons = new Dictionary();
			m_injectionPointLists = new Dictionary();
			m_constructorInjectionPoints = new Dictionary();
			m_attendedToInjectees = new Dictionary(true);
			m_xmlMetadata = xmlConfig;
		}
		
		public function mapValue(
			whenAskedFor : Class, useValue : Object, named : String = "") : *
		{
			var config : InjectionConfig = new InjectionConfig(
				whenAskedFor, useValue, InjectionType.VALUE, named);
			addMapping(config, named);
			return config;
		}
		
		public function mapClass(
			whenAskedFor : Class, instantiateClass : Class, named : String = "") : *
		{
			var config : InjectionConfig = new InjectionConfig(
				whenAskedFor, instantiateClass, InjectionType.CLASS, named);
			addMapping(config, named);
			return config;
		}
		
		public function mapSingleton(whenAskedFor : Class, named : String = "") : *
		{
			return mapSingletonOf(whenAskedFor, whenAskedFor, named);
		}
		
		public function mapSingletonOf(
			whenAskedFor : Class, useSingletonOf : Class, named : String = "") : *
		{
			var config : InjectionConfig = new InjectionConfig(
				whenAskedFor, useSingletonOf, InjectionType.SINGLETON, named);
			addMapping(config, named);
			return config;
		}
		
		public function mapRule(
			whenAskedFor : Class, useRule : *, named : String = "") : *
		{
			addMapping(useRule, named, getQualifiedClassName(whenAskedFor));
			return useRule;
		}
		
		public function injectInto(target : Object) : void
		{
			if (m_attendedToInjectees[target])
			{
				return;
			}
			m_attendedToInjectees[target] = true;
			
			//get injection points or cache them if this targets' class wasn't encountered before
			var injectionPoints : Array;
			
			var ctor : Class;
			if (target is Proxy)
			{
				//for classes extending Proxy, we can't access the 'constructor' property because 
				//the Proxy will throw if we try. So let's take the scenic route ...
				var name : String = getQualifiedClassName(target);
				ctor = Class(getDefinitionByName(name));
			}
			else
			{
				ctor = target.constructor;
			}
			
			injectionPoints = m_injectionPointLists[ctor] || getInjectionPoints(ctor);
			
			var length : int = injectionPoints.length;
			for (var i : int = 0; i < length; i++)
			{
				var injectionPoint : InjectionPoint = injectionPoints[i];
				injectionPoint.applyInjection(target, this, m_singletons);
			}
			
		}
		
		public function instantiate(clazz:Class):*
		{
			var injectionPoint : InjectionPoint = m_constructorInjectionPoints[clazz];
			if (!injectionPoint)
			{
				getInjectionPoints(clazz);
				injectionPoint = m_constructorInjectionPoints[clazz];
			}
			var instance : * = injectionPoint.applyInjection(clazz, this, m_singletons);
			injectInto(instance);
			return instance;
		}
		
		public function unmap(clazz : Class, named : String = "") : void
		{
			var requestName : String = getQualifiedClassName(clazz);
			if (named && m_mappings[named])
			{
				delete Dictionary(m_mappings[named])[requestName];
			}
			else
			{
				delete m_mappings[requestName];
			}
		}
		
		
		/*******************************************************************************************
		*								protected/ private methods								   *
		*******************************************************************************************/
		private function addMapping(
			config : InjectionConfig, named : String, requestName : String = null) : void
		{
			if (!requestName)
			{
				requestName = getQualifiedClassName(config.request);
			}
			if (named)
			{
				var nameMappings : Dictionary = m_mappings[named];
				if (!nameMappings)
				{
					nameMappings = m_mappings[named] = new Dictionary();
				}
				nameMappings[requestName] = config;
			}
			else
			{
				m_mappings[requestName] = config;
			}
		}
		
		private function getInjectionPoints(clazz : Class) : Array
		{
			var description : XML = describeType(clazz);
			var injectionPoints : Array = [];
			m_injectionPointLists[clazz] = injectionPoints;
			m_injectionPointLists[description.@name.toString()] = injectionPoints;
			var node : XML;
			
			// This is where we have to wire in the XML...
			if(m_xmlMetadata)
			{
				createInjectionPointsFromConfigXML(description);
				addParentInjectionPoints(description, injectionPoints);
			}
			
			var injectionPoint : InjectionPoint;
			//get constructor injections
			node = description.factory.constructor[0];
			if (node)
			{
				m_constructorInjectionPoints[clazz] = 
						new ConstructorInjectionPoint(node, m_mappings, clazz);
			}
			else
			{
				m_constructorInjectionPoints[clazz] = new NoParamsConstructorInjectionPoint();
			}
			//get injection points for variables
			for each (node in description.factory.*.
				(name() == 'variable' || name() == 'accessor').metadata.(@name == 'Inject'))
			{
				injectionPoint = new PropertyInjectionPoint(node, m_mappings);
				injectionPoints.push(injectionPoint);
			}
		
			//get injection points for methods
			for each (node in description.factory.method.metadata.(@name == 'Inject'))
			{
				injectionPoint = new MethodInjectionPoint(node, m_mappings);
				injectionPoints.push(injectionPoint);
			}
			
			//get post construct methods
			var postConstructMethodPoints : Array = [];
			for each (node in description.factory.method.metadata.(@name == 'PostConstruct'))
			{
				injectionPoint = new PostConstructInjectionPoint(node, m_mappings);
				postConstructMethodPoints.push(injectionPoint);
			}
			if (postConstructMethodPoints.length > 0)
			{
				postConstructMethodPoints.sortOn("order", Array.NUMERIC);
				injectionPoints.push.apply(injectionPoints, postConstructMethodPoints);
			}
			
			return injectionPoints;
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
			for each (node in m_xmlMetadata.type.(@name == className).children())
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
			var parentInjectionPoints : Array = m_injectionPointLists[parentClassName] || 
					getInjectionPoints(Class(getDefinitionByName(parentClassName)));
			injectionPoints.push.apply(injectionPoints, parentInjectionPoints);
		}
	}
}