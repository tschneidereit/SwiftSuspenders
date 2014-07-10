/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flexunit.framework.Assert;

	import org.swiftsuspenders.mapping.InjectionMapping;

	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.injectees.childinjectors.ChildInjectorCreatingProvider;
	import org.swiftsuspenders.support.injectees.childinjectors.InjectorInjectee;
	import org.swiftsuspenders.support.injectees.childinjectors.LeftRobotFoot;
	import org.swiftsuspenders.support.injectees.childinjectors.NestedInjectorInjectee;
	import org.swiftsuspenders.support.injectees.childinjectors.RightRobotFoot;
	import org.swiftsuspenders.support.injectees.childinjectors.RobotAnkle;
	import org.swiftsuspenders.support.injectees.childinjectors.RobotBody;
	import org.swiftsuspenders.support.injectees.childinjectors.RobotFoot;
	import org.swiftsuspenders.support.injectees.childinjectors.RobotLeg;
	import org.swiftsuspenders.support.injectees.childinjectors.RobotToes;
	import org.swiftsuspenders.support.providers.ProviderThatCanDoInterfaces;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.Interface;
	import org.swiftsuspenders.utils.SsInternal;
	import org.swiftsuspenders.dependencyproviders.ClassProvider;

	use namespace SsInternal;

	public class ChildInjectorTests
	{
		protected var injector:Injector;
		
		[Before]
		public function runBeforeEachTest():void
		{
			injector = new Injector();
		}

		[After]
		public function teardown():void
		{
			Injector.SsInternal::purgeInjectionPointsCache();
			injector = null;
		}
		
		[Test]
		public function injectorCreatesChildInjector() : void
		{
			Assert.assertTrue(true);
			var childInjector : Injector = injector.createChildInjector();
			Assert.assertTrue('injector.createChildInjector should return an injector', 
				childInjector is Injector);
		}
		
		[Test]
		public function injectorUsesChildInjectorForSpecifiedMapping() : void
		{
			injector.map(RobotFoot);

			var leftFootMapping : InjectionMapping = injector.map(RobotLeg, 'leftLeg');
			var leftChildInjector : Injector = injector.createChildInjector();
			leftChildInjector.map(RobotAnkle);
			leftChildInjector.map(RobotFoot).toType(LeftRobotFoot);

			leftFootMapping.setInjector(leftChildInjector);
			var rightFootMapping : InjectionMapping = injector.map(RobotLeg, 'rightLeg');
			var rightChildInjector : Injector = injector.createChildInjector();
			rightChildInjector.map(RobotAnkle);
			rightChildInjector.map(RobotFoot).toType(RightRobotFoot);
			rightFootMapping.setInjector(rightChildInjector);
			
			var robotBody : RobotBody = injector.instantiateUnmapped(RobotBody);
			
			Assert.assertTrue('Right RobotLeg should have a RightRobotFoot', 
				robotBody.rightLeg.ankle.foot is RightRobotFoot);
			Assert.assertTrue('Left RobotLeg should have a LeftRobotFoot', 
				robotBody.leftLeg.ankle.foot is LeftRobotFoot);
		}

		[Test]
		public function childInjectorUsesParentForMissingMappings() : void
		{
			injector.map(RobotFoot);
			injector.map(RobotToes);

			var leftFootMapping : InjectionMapping = injector.map(RobotLeg, 'leftLeg');
			var leftChildInjector : Injector = injector.createChildInjector();
			leftChildInjector.map(RobotAnkle);
			leftChildInjector.map(RobotFoot).toType(LeftRobotFoot);
			leftFootMapping.setInjector(leftChildInjector);

			var rightFootMapping : InjectionMapping = injector.map(RobotLeg, 'rightLeg');
			var rightChildInjector : Injector = injector.createChildInjector();
			rightChildInjector.map(RobotAnkle);
			rightChildInjector.map(RobotFoot).toType(RightRobotFoot);
			rightFootMapping.setInjector(rightChildInjector);

			var robotBody : RobotBody = injector.instantiateUnmapped(RobotBody);

			Assert.assertTrue('Right RobotFoot should have toes',
				robotBody.rightLeg.ankle.foot.toes is RobotToes);
			Assert.assertTrue('Left Robotfoot should have a toes',
				robotBody.leftLeg.ankle.foot.toes is RobotToes);
		}

		[Test]
		public function parentMappedSingletonGetsInitializedByParentWhenInvokedThroughChildInjector() : void
		{
			var parentClazz : Clazz = new Clazz();
			injector.map(Clazz).toValue(parentClazz);
			injector.map(ClassInjectee).asSingleton();
			var childInjector : Injector = injector.createChildInjector();
			var childClazz : Clazz = new Clazz();
			childInjector.map(Clazz).toValue(childClazz);

			var classInjectee : ClassInjectee = childInjector.getInstance(ClassInjectee);

			Assert.assertEquals('classInjectee.property is injected with value mapped in parent injector',
					classInjectee.property, parentClazz);
		}

		[Test]
		public function childInjectorDoesntReturnToParentAfterUsingParentInjectorForMissingMappings() : void
		{
			injector.map(RobotAnkle);
			injector.map(RobotFoot);
			injector.map(RobotToes);

			var leftFootMapping : InjectionMapping = injector.map(RobotLeg, 'leftLeg');
			var leftChildInjector : Injector = injector.createChildInjector();
			leftChildInjector.map(RobotFoot).toType(LeftRobotFoot);
			leftFootMapping.setInjector(leftChildInjector);

			var rightFootMapping : InjectionMapping = injector.map(RobotLeg, 'rightLeg');
			var rightChildInjector : Injector = injector.createChildInjector();
			rightChildInjector.map(RobotFoot).toType(RightRobotFoot);
			rightFootMapping.setInjector(rightChildInjector);

			var robotBody : RobotBody = injector.instantiateUnmapped(RobotBody);

			Assert.assertEquals('Right RobotFoot should have RightRobotFoot',
					RightRobotFoot, robotBody.rightLeg.ankle.foot['constructor']);
			Assert.assertTrue('Left RobotFoot should have LeftRobotFoot',
					LeftRobotFoot, robotBody.leftLeg.ankle.foot['constructor']);
		}
        
        [Test]
        public function childInjectorHasMappingWhenExistsOnParentInjector():void
        {
            var childInjector : Injector = injector.createChildInjector();
            var class1 : Clazz = new Clazz();
            injector.map(Clazz).toValue(class1);
            
            Assert.assertTrue('Child injector should return true for satisfies that exists on parent injector',
                childInjector.satisfies(Clazz));
        }
        
        [Test]
        public function childInjectorDoesNotHaveMappingWhenDoesNotExistOnParentInjector():void
        {
            var childInjector : Injector = injector.createChildInjector();
            
            Assert.assertFalse('Child injector should not return true for satisfies that does ' +
	            'not exists on parent injector',
                childInjector.satisfies(Interface));
        }  
        
        [Test]
        public function grandChildInjectorSuppliesInjectionFromAncestor():void
        {
            var childInjector:Injector;
            var grandChildInjector:Injector;
            var injectee:ClassInjectee = new ClassInjectee();
            injector.map(Clazz).toSingleton(Clazz);
            childInjector = injector.createChildInjector();
            grandChildInjector = childInjector.createChildInjector();
            
            grandChildInjector.injectInto(injectee);
            
            Assert.assertTrue("injectee has been injected with Clazz instance from grandChildInjector", 
                injectee.property is Clazz); 
        }

		[Test]
		public function injectorCanCreateChildInjectorDuringInjection():void
		{
			injector.map(Injector).toProvider(new ChildInjectorCreatingProvider());
			injector.map(InjectorInjectee);
			injector.map(NestedInjectorInjectee);
			var injectee : InjectorInjectee = injector.getInstance(InjectorInjectee);
			Assert.assertNotNull('Injection has been applied to injectorInjectee', injectee.injector);
			Assert.assertTrue('injectorInjectee.injector is child of main injector',
					injectee.injector.parentInjector == injector);
			Assert.assertTrue('injectorInjectee.nestedInjectee is grandchild of main injector',
					injectee.nestedInjectee.injector.parentInjector.parentInjector == injector);
		}
		
		[Test]
		public function satisfies_with_fallbackProvider_trickles_down_to_children():void
		{
			injector.fallbackProvider = new ProviderThatCanDoInterfaces(Clazz);
			const childInjector:Injector = injector.createChildInjector();
			Assert.assertTrue(childInjector.satisfies(Clazz));
		}
		
		[Test]
		public function getInstance_with_fallbackProvider_trickles_down_to_children():void
		{
			injector.fallbackProvider = new ProviderThatCanDoInterfaces(Clazz);
			const childInjector:Injector = injector.createChildInjector();
			Assert.assertTrue(childInjector.getInstance(Clazz) != null);
		}
		
	}
}
