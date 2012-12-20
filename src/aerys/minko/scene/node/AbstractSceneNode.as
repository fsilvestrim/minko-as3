package aerys.minko.scene.node
{
	import aerys.minko.ns.minko_scene;
	import aerys.minko.render.shader.part.phong.attenuation.MatrixShadowMapAttenuationShaderPart;
	import aerys.minko.scene.controller.AbstractController;
	import aerys.minko.scene.controller.IRebindableController;
	import aerys.minko.scene.controller.TransformController;
	import aerys.minko.type.Signal;
	import aerys.minko.type.clone.CloneOptions;
	import aerys.minko.type.clone.ControllerCloneAction;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	use namespace minko_scene;
	
	/**
	 * The base class to extend in order to create new scene node types.
	 *  
	 * @author Jean-Marc Le Roux
	 * 
	 */
	public class AbstractSceneNode implements ISceneNode
	{
		private static var _id	    	    	: uint;
        
		private var _name	    	    		: String;
		private var _root	        			: ISceneNode;
		private var _parent	        			: Group;
        
        private var _visible                    : Boolean;
        private var _computedVisibility         : Boolean;
		
		private var _transform			        : Matrix4x4;
		
		private var _controllers		        : Vector.<AbstractController>;
		
		private var _added				        : Signal;
		private var _removed			        : Signal;
		private var _addedToScene		        : Signal;
		private var _removedFromScene	        : Signal;
		private var _controllerAdded	        : Signal;
		private var _controllerRemoved	        : Signal;
        private var _visibilityChanged          : Signal;
        private var _computedVisibilityChanged  : Signal;
		private var _localToWorldChanged		: Signal;

        final public function get x() : Number
		{
			return _transform.translationX;
		}
        final public function set x(value : Number) : void
		{
			_transform.translationX = value;
		}
		
        final public function get y() : Number
		{
			return _transform.translationX;
		}
        final public function set y(value : Number) : void
		{
			_transform.translationY = value;
		}
		
        final public function get z() : Number
		{
			return _transform.translationX;
		}
        final public function set z(value : Number) : void
		{
			_transform.translationZ = value;
		}
		
        final public function get rotationX() : Number
		{
			return _transform.rotationX;
		}
        final public function set rotationX(value : Number) : void
		{
			_transform.rotationX = value;
		}
		
        final public function get rotationY() : Number
		{
			return _transform.rotationY;
		}
        final public function set rotationY(value : Number) : void
		{
			_transform.rotationY = value;
		}
		
        final public function get rotationZ() : Number
		{
			return _transform.rotationZ;
		}
        final public function set rotationZ(value : Number) : void
		{
			_transform.rotationZ = value;
		}
		
        final public function get scaleX() : Number
		{
			return _transform.scaleX;
		}
        final public function set scaleX(value : Number) : void
		{
			_transform.scaleX = value;
		}
		
        final public function get scaleY() : Number
		{
			return _transform.scaleY;
		}
        final public function set scaleY(value : Number) : void
		{
			_transform.scaleY = value;
		}
		
        final public function get scaleZ() : Number
		{
			return _transform.scaleZ;
		}
        final public function set scaleZ(value : Number) : void
		{
			_transform.scaleZ = value;
		}
		
        public function get name() : String
		{
			return _name;
		}
        public function set name(value : String) : void
		{
			_name = value;
		}
		
        final public function get parent() : Group
		{
			return _parent;
		}
        final public function set parent(value : Group) : void
		{
			if (value == _parent)
				return ;
			
			// remove child
			if (_parent)
			{
				var oldParent : Group = _parent;
				
				oldParent._children.splice(oldParent.getChildIndex(this), 1);
				
				parent._numChildren--;
				_parent = null;
				_removed.execute(this, oldParent);
				updateRoot();
				oldParent.descendantRemoved.execute(oldParent, this);
			}
			
			// set parent
			_parent = value;
			
			// add child
			if (_parent)
			{
				_parent._children[_parent.numChildren] = this;
				_parent._numChildren++;
				_added.execute(this, _parent);
				updateRoot();
				_parent.descendantAdded.execute(_parent, this);
			}
		}
		
        final public function get scene() : Scene
        {
            return _root as Scene;
        }
        
        final public function get root() : ISceneNode
		{
			return _root;
		}
        
        final public function get transform() : Matrix4x4
		{
			return _transform;
		}
		
        final public function get added() : Signal
		{
			return _added;
		}
		
        final public function get removed() : Signal
		{
			return _removed;
		}

        final public function get addedToScene() : Signal
		{
			return _addedToScene;
		}
		
        final public function get removedFromScene() : Signal
		{
			return _removedFromScene;
		}
		
		public function get numControllers() : uint
		{
			return _controllers.length;
		}
		
		public function get controllerAdded() : Signal
		{
			return _controllerAdded;
		}
		
		public function get controllerRemoved() : Signal
		{
			return _controllerRemoved;
		}
		
		public function get localToWorldTransformChanged() : Signal
		{
			return _localToWorldChanged;
		}
        
		public function AbstractSceneNode()
		{
			initialize();
		}
		
		private function initialize() : void
		{
			_name = getDefaultSceneName(this);
			
            _visible = true;
            _computedVisibility = true;
            
			_transform = new Matrix4x4();
			
			_controllers = new <AbstractController>[];
			
			_added = new Signal('AbstractSceneNode.added');
			_removed = new Signal('AbstractSceneNode.removed');
			_addedToScene = new Signal('AbstractSceneNode.addedToScene');
			_removedFromScene = new Signal('AbstractSceneNode.removedFromScene');
			_controllerAdded = new Signal('AbstractSceneNode.controllerAdded');
			_controllerRemoved = new Signal('AbstractSceneNode.controllerRemoved');
            _visibilityChanged = new Signal('AbstractSceneNode.visibilityChanged');
            _computedVisibilityChanged = new Signal('AbstractSceneNode.computedVisibilityChanged');
			_localToWorldChanged = new Signal('AbstractSceneNode.localToWorldChanged');
			
			updateRoot();
			addController(new TransformController());
            
			_added.add(addedHandler);
			_removed.add(removedHandler);
			_addedToScene.add(addedToSceneHandler);
			_removedFromScene.add(removedFromSceneHandler);
		}
		
		protected function addedHandler(child : ISceneNode, ancestor : Group) : void
		{
            updateRoot();
		}
        
		protected function removedHandler(child : ISceneNode, ancestor : Group) : void
		{
			updateRoot();
		}
		
        minko_scene function updateRoot() : void
        {
            var newRoot : ISceneNode    = _parent ? _parent.root : this;
            var oldRoot : ISceneNode    = _root;
            
            if (newRoot != oldRoot)
            {
                _root = newRoot;
                if (oldRoot is Scene)
                    _removedFromScene.execute(this, oldRoot);
                if (newRoot is Scene)
                    _addedToScene.execute(this, newRoot);
            }
        }
        
		protected function addedToSceneHandler(child : ISceneNode, scene : Scene) : void
		{
			// nothing
		}
		
		protected function removedFromSceneHandler(child : ISceneNode, scene : Scene) : void
		{
			// nothing
		}
        
		public function addController(controller : AbstractController) : ISceneNode
		{
			_controllers.push(controller);
			
			controller.addTarget(this);
			_controllerAdded.execute(this, controller);
			
			return this;
		}
		
		public function removeController(controller : AbstractController) : ISceneNode
		{
			var numControllers	: uint  = _controllers.length - 1;
            var controllerId    : int   = _controllers.indexOf(controller);
            
            if (controllerId < 0)
                throw new Error('The controller is not on the node.');
			
			_controllers[controllerId] = _controllers[numControllers];
			_controllers.length = numControllers;
			
			controller.removeTarget(this);
			_controllerRemoved.execute(this, controller);
			
			return this;
		}
		
		public function getController(index : uint) : AbstractController
		{
			return _controllers[index];
		}
		
		public function getControllersByType(type			: Class,
											 controllers	: Vector.<AbstractController> = null) : Vector.<AbstractController>
		{
			controllers ||= new Vector.<AbstractController>();
			
			var nbControllers : uint = numControllers;
			
			for (var i : int = 0; i < nbControllers; ++i)
			{
				var ctrl 	: AbstractController	= getController(i);
				
				if (ctrl is type)
					controllers.push(ctrl);
			}
			
			return controllers;
		}
		
		public static function getDefaultSceneName(scene : ISceneNode) : String
		{
			var className : String = getQualifiedClassName(scene);

			return className.substr(className.lastIndexOf(':') + 1)
				   + '_' + (++_id);
		}
		
		minko_scene function cloneNode() : AbstractSceneNode
		{
			throw new Error('Must be overriden');
		}
		
		public final function clone(cloneOptions : CloneOptions = null) : ISceneNode
		{
			cloneOptions ||= CloneOptions.defaultOptions;
			
			// fill up 2 dics with all nodes and controllers
			var nodeMap			: Dictionary = new Dictionary();
			var controllerMap	: Dictionary = new Dictionary();
			listItems(cloneNode(), nodeMap, controllerMap);
			
			// clone controllers with respect with instructions
			cloneControllers(controllerMap, cloneOptions);
			
			// rebind all controller dependencies.
			rebindControllerDependencies(controllerMap, nodeMap, cloneOptions);
			
			// add cloned/rebinded/original controllers to clones
			for (var objNode : Object in nodeMap)
			{
				var node			: AbstractSceneNode = AbstractSceneNode(objNode);
				var numControllers	: uint = node.numControllers;
				
				for (var controllerId : uint = 0; controllerId < numControllers; ++controllerId)
				{
					var controller : AbstractController = controllerMap[node.getController(controllerId)];
					if (controller != null)
						nodeMap[node].addController(controller);
				}
			}
			
			return nodeMap[this];
		}
		
		minko_scene function getLocalToWorldTransformUnsafe() : Matrix4x4
		{
			var transformController : TransformController = root.getControllersByType(
				TransformController
			)[0] as TransformController;
			
			return transformController.getLocalToWorldTransform(this);
		}
		
		public function getLocalToWorldTransform(output : Matrix4x4 = null) : Matrix4x4
		{
			output ||= new Matrix4x4();
			output.copyFrom(getLocalToWorldTransformUnsafe());
			
			return output;
		}
		
		public function getWorldToLocalTransform(output : Matrix4x4 = null) : Matrix4x4
		{
			return getLocalToWorldTransform(output).invert();
		}
		
		public function localToWorld(vector : Vector4, output : Vector4 = null) : Vector4
		{
			var localToWorld : Matrix4x4 = getLocalToWorldTransformUnsafe();
			
			return localToWorld.transformVector(vector, output);
		}
		
		public function deltaLocalToWorld(vector : Vector4, output : Vector4 = null) : Vector4
		{
			var localToWorld : Matrix4x4 = getLocalToWorldTransformUnsafe();
			
			return localToWorld.deltaTransformVector(vector, output);
		}
		
		private function listItems(clonedRoot	: ISceneNode,
								   nodes		: Dictionary,
								   controllers	: Dictionary) : void
		{
			var numControllers : uint = this.numControllers;
			for (var controllerId : uint = 0; controllerId < numControllers; ++controllerId)
				controllers[getController(controllerId)] = true;
			
			nodes[this] = clonedRoot;
			
			if (this is Group)
			{
				var group		: Group = Group(this);
				var clonedGroup	: Group = Group(clonedRoot);
				var numChildren	: uint	= group.numChildren;
				
				for (var childId : uint = 0; childId < numChildren; ++childId)
				{
					var child		: AbstractSceneNode = AbstractSceneNode(group.getChildAt(childId));
					var clonedChild	: AbstractSceneNode = AbstractSceneNode(clonedGroup.getChildAt(childId));
					
					child.listItems(clonedChild, nodes, controllers);
				}
			}
		}
		
		private function cloneControllers(controllerMap : Dictionary, cloneOptions : CloneOptions) : void
		{
			for (var objController : Object in controllerMap)
			{
				var controller	: AbstractController = AbstractController(objController);
				var action		: uint				 = cloneOptions.getActionForController(controller);
				
				if (action == ControllerCloneAction.CLONE)
					controllerMap[controller] = controller.clone();
				else if (action == ControllerCloneAction.REASSIGN)
					controllerMap[controller] = controller;
				else if (action == ControllerCloneAction.IGNORE)
					controllerMap[controller] = null;
				else
					throw new Error();
			}
		}
		
		private function rebindControllerDependencies(controllerMap	: Dictionary,
													  nodeMap		: Dictionary,
													  cloneOptions	: CloneOptions) : void
		{
			for (var objController : Object in controllerMap)
			{
				var controller	: AbstractController	= AbstractController(objController);
				var action		: uint					= cloneOptions.getActionForController(controller);
				
				if (controller is IRebindableController && action == ControllerCloneAction.CLONE)
					IRebindableController(controllerMap[controller]).rebindDependencies(nodeMap, controllerMap);
			}
		}
	}
}