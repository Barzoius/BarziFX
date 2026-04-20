@tool

extends CompositorEffect

class_name PixelEffect

var rd := RenderingServer.get_rendering_device()
var shader := RID()
var pipeline := RID()
var param_storage_buffer := RID()

func _init() -> void:
	var shader_file : RDShaderFile = load("res://shaders/compute_shaders/pixel.glsl");
	var shader_spirv := shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)
	
	var param_data := PackedFloat32Array([0.0, 0.0, 0.0, 0.0]).to_byte_array()
	param_storage_buffer = rd.storage_buffer_create(param_data.size(), param_data)

func _render_callback(_callback_type: int, render_data: RenderData) -> void:
	var render_scene_buffers : RenderSceneBuffersRD= render_data.get_render_scene_buffers() 
	if !render_scene_buffers:
		return
	var size := render_scene_buffers.get_internal_size()
	if size.x == 0 or size.y == 0:
		return
	
	var groups : Vector3i = Vector3((size.x - 1.0) / 8.0 + 1.0, (size.y - 1.0) / 8.0 + 1.0, 1.0).floor()
	var param_data := PackedFloat32Array([size.x, size.y, 0.0, 0.0]).to_byte_array()
	rd.buffer_update(param_storage_buffer, 0, param_data.size(), param_data)
	
	var param_uniform := RDUniform.new()
	param_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	param_uniform.binding = 0
	param_uniform.add_id(param_storage_buffer)
	
	var color_layer_uniform := RDUniform.new()
	color_layer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	color_layer_uniform.binding = 1
	color_layer_uniform.add_id(render_scene_buffers.get_color_layer(0))
	
	var bindings: Array[RDUniform] = [
		param_uniform,
		color_layer_uniform
	]
	
	var uniform_set := rd.uniform_set_create(bindings, shader, 0)
	
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
	rd.compute_list_end()
	rd.free_rid(uniform_set)
