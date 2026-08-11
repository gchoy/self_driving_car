components {
  id: "car"
  component: "/main/car.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/car.atlas\"\n"
  "}\n"
  ""
  position {
    x: 1.0
    y: 1.0
  }
  scale {
    x: 2.0445
    y: 1.769386
    z: 2.0022
  }
}
