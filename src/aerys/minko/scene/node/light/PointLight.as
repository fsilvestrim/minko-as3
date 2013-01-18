package aerys.minko.scene.node.light
{
	import aerys.minko.ns.minko_scene;
	import aerys.minko.render.material.phong.PhongProperties;
	import aerys.minko.render.resource.texture.CubeTextureResource;
	import aerys.minko.render.resource.texture.ITextureResource;
	import aerys.minko.render.resource.texture.TextureResource;
	import aerys.minko.scene.controller.light.PointLightController;
	import aerys.minko.scene.node.AbstractSceneNode;
	import aerys.minko.scene.node.ISceneNode;
	import aerys.minko.scene.node.Scene;
	import aerys.minko.type.binding.DataBindings;
	import aerys.minko.type.enum.ShadowMappingType;
	import aerys.minko.type.math.Matrix4x4;
	import aerys.minko.type.math.Vector4;

	use namespace minko_scene;
	
	/**
	 * 
	 * @author Romain Gilliotte
	 * @author Jean-Marc Le Roux
	 * 
	 */
	public class PointLight extends AbstractLight
	{
		public static const LIGHT_TYPE : uint = 2;
		
		private static const TMP_VECTOR		: Vector4 = new Vector4();
		
		public function get diffuse() : Number
		{
			return lightData.getLightProperty('diffuse') as Number;
		}
		public function set diffuse(v : Number)	: void
		{
			lightData.setLightProperty('diffuse', v);
			
			if (lightData.getLightProperty('diffuseEnabled') != (v != 0))
				lightData.setLightProperty('diffuseEnabled', v != 0);
		}
		
		public function get specular() : Number
		{
			return lightData.getLightProperty('specular') as Number;
		}
		public function set specular(v : Number) : void
		{
			lightData.setLightProperty('specular', v);
			
			if (lightData.getLightProperty('specularEnabled') != (v != 0))
				lightData.setLightProperty('specularEnabled', v != 0);
		}
		
		public function get shininess() : Number
		{
			return lightData.getLightProperty('shininess') as Number;
		}
		public function set shininess(v : Number) : void
		{
			lightData.setLightProperty('shininess', v);
		}
		
		public function get attenuationDistance() : Number
		{
			return lightData.getLightProperty('attenuationDistance') as Number;
		}
		public function set attenuationDistance(v : Number) : void
		{
			lightData.setLightProperty('attenuationDistance', v);
			
			if (lightData.getLightProperty('attenuationEnabled') != (v != 0))
				lightData.setLightProperty('attenuationEnabled', v != 0);
		}
		
		public function get shadowMapSize() : uint
		{
			return lightData.getLightProperty('shadowMapSize');
		}
		public function set shadowMapSize(v : uint) : void
		{
			lightData.setLightProperty('shadowMapSize', v);
		}
		
		public function get shadowZNear() : Number
		{
			return lightData.getLightProperty('shadowZNear');
		}
		public function set shadowZNear(v : Number) : void
		{
			lightData.setLightProperty('shadowZNear', v);
		}
		
		public function get shadowZFar() : Number
		{
			return lightData.getLightProperty('shadowZFar');
		}
		public function set shadowZFar(v : Number) : void
		{
			lightData.setLightProperty('shadowZFar', v);
		}
		
		public function get shadowCastingType() : uint
		{
			return lightData.getProperty('shadowCastingType');
		}
		public function set shadowCastingType(value : uint) : void
		{
			lightData.setLightProperty('shadowCastingType', value);
		}
        
        public function get shadowBias() : Number
        {
            return lightData.getLightProperty(PhongProperties.SHADOW_BIAS);
        }
        public function set shadowBias(value : Number) : void
        {
            lightData.setLightProperty(PhongProperties.SHADOW_BIAS, value);
        }
		
		public function PointLight(color				: uint		= 0xFFFFFFFF,
								   diffuse				: Number	= .6,
								   specular				: Number	= .8,
								   shininess			: Number	= 64,
								   attenuationDistance	: Number	= 0,
								   emissionMask			: uint		= 0x1,
								   shadowCastingType	: uint		= 0,
								   shadowMapSize		: uint		= 512,
								   shadowZNear			: Number	= 0.1,
								   shadowZFar			: Number	= 1000.,
                                   shadowBias           : uint      = 1. / 256. / 256.)
		{
			super(
				new PointLightController(),
				LIGHT_TYPE,
				color,
				emissionMask
			);
			
			this.diffuse				= diffuse;
			this.specular				= specular;
			this.shininess				= shininess;
			this.attenuationDistance	= attenuationDistance;
			this.shadowCastingType		= shadowCastingType;
            this.shadowMapSize          = shadowMapSize;
			this.shadowZNear			= shadowZNear;
			this.shadowZFar		    	= shadowZFar;
            this.shadowBias             = shadowBias;
		}
		
		override minko_scene function cloneNode() : AbstractSceneNode
		{
			var light : PointLight = new PointLight(
				color,
				diffuse,
				specular,
				shininess, 
				attenuationDistance,
				emissionMask, 
				shadowCastingType,
				shadowMapSize,
				shadowZFar,
				shadowZNear,
				shadowBias
			);		
			
			light.name = this.name;
			light.transform.copyFrom(this.transform);
			
			return light;
		}
	}
}
