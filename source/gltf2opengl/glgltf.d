module gltf2opengl.glgltf;
import gltf2opengl.glutil, gltf2, gltf2opengl.glgltfenum;
import std.stdio;
    import std.variant : visit;
import std.algorithm, std.array, std.range;
/*version(glTFViewer)*/ import gl3n.linalg;
// ----- glTF (root object) ----------------------------------------------------
class GL_glTFObject {
  glTFObject gltf;

  GL_glTFAccessor   []    accessors;
  GL_glTFAnimation  []   animations;
  GL_glTFBuffer     []      buffers;
  GL_glTFBufferView [] buffer_views;
  GL_glTFImage      []       images;
  GL_glTFMaterial   []    materials;
  GL_glTFMesh       []       meshes;
  GL_glTFNode       []        nodes;
  GL_glTFSampler    []     samplers;
  GL_glTFScene      []       scenes;
  GL_glTFSkin       []        skins;
  GL_glTFTexture    []     textures;

  GL_glTFAccessor* RglTFAccessor ( glTFAccessor* accessor ) {
    return &accessors[accessor.buffer_index];
  } GL_glTFAnimation* RglTFAnimation ( glTFAnimation* animation ) {
    return &animations[animation.buffer_index];
  } GL_glTFBuffer* RGL_glTFBuffer ( glTFBuffer* buffer ) {
    return &buffers[buffer.buffer_index];
  } GL_glTFBufferView* RGL_glTFBufferView ( glTFBufferView* buffer_view ) {
    return &buffer_views[buffer_view.buffer_index];
  } GL_glTFImage* RGL_glTFImage ( glTFImage* image ) {
    return &images[image.buffer_index];
  } GL_glTFMaterial* RGL_glTFMaterial ( glTFMaterial* material ) {
    return &materials[material.buffer_index];
  } GL_glTFMesh* RGL_glTFMesh ( glTFMesh* meshe ) {
    return &meshes[meshe.buffer_index];
  } GL_glTFNode* RGL_glTFNode ( glTFNode* node ) {
    return &nodes[node.buffer_index];
  } GL_glTFSampler* RGL_glTFSampler ( glTFSampler* sampler ) {
    return &samplers[sampler.buffer_index];
  } GL_glTFScene* RGL_glTFScene ( glTFScene* scene ) {
    return &scenes[scene.buffer_index];
  } GL_glTFSkin* RGL_glTFSkin ( glTFSkin* skin ) {
    return &skins[skin.buffer_index];
  } GL_glTFTexture* RGL_glTFTexture ( glTFTexture* texture ) {
    return &textures[texture.buffer_index];
  }

  this ( glTFObject _gltf ) {
    gltf = _gltf;

    // set buffer lengths
    accessors.length    = gltf.accessors.length;
    animations.length   = gltf.animations.length;
    samplers.length     = gltf.samplers.length;
    textures.length     = gltf.textures.length;
    buffers.length      = gltf.buffers.length;
    buffer_views.length = gltf.buffer_views.length;
    images.length       = gltf.images.length;
    materials.length    = gltf.materials.length;
    meshes.length       = gltf.meshes.length;
    nodes.length        = gltf.nodes.length;
    scenes.length       = gltf.scenes.length;
    skins.length        = gltf.skins.length;

    void Fill_Buff(T, U)(ref T[] buff, ref U[] gl) {
      import std.range, std.algorithm;
      iota(0, gl.length).each!((i) { buff[i] = T(this, gl[i]); });
    }
    // create GL_glTF buffers from glTF data
    // (this has to be ordered correctly)
    Fill_Buff(textures,     gltf.textures);
    Fill_Buff(materials,    gltf.materials);
    Fill_Buff(buffers,      gltf.buffers);
    Fill_Buff(buffer_views, gltf.buffer_views);
    Fill_Buff(accessors,    gltf.accessors);
    Fill_Buff(animations,   gltf.animations);
    Fill_Buff(images,       gltf.images);
    Fill_Buff(meshes,       gltf.meshes);
    Fill_Buff(nodes,        gltf.nodes);
    Fill_Buff(samplers,     gltf.samplers);
    Fill_Buff(scenes,       gltf.scenes);
    Fill_Buff(skins,        gltf.skins);
  }
}

// ----- accessor --------------------------------------------------------------
struct GL_glTFAccessor {
  glTFAccessor* gltf;
  this ( GL_glTFObject obj, ref glTFAccessor _gltf ) {
    gltf = &_gltf;
  }
}
// ----- animation -------------------------------------------------------------
struct GL_glTFAnimation {
  glTFAnimation* gltf;
  this ( GL_glTFObject obj, ref glTFAnimation _gltf ) {
    gltf = &_gltf;
  }
}
// ----- buffer ----------------------------------------------------------------
struct GL_glTFBuffer {
  glTFBuffer* gltf;
  this ( GL_glTFObject obj, ref glTFBuffer _gltf ) {
    gltf = &_gltf;
  }
}
struct GL_glTFBufferView {
  glTFBufferView* gltf;
  GLuint buffer;
  GLenum target;
  this ( GL_glTFObject obj, ref glTFBufferView _gltf ) {
    gltf = &_gltf;
    // -- generate and buffer data --
    target = GL_glTFBufferViewTarget_Info(gltf.target).gl_target;
    if ( target == glTFBufferViewTarget.NonGPU ) return;
    buffer = GL_glTFCreate_Buffer(target);
    glBufferData(target, gltf.length, gltf.buffer.raw_data.ptr + gltf.offset,
                 GL_STATIC_DRAW);
  }
  void Bind ( ) {
    glBindBuffer(target, buffer);
  }
  void Vertex_Attrib_Pointer(GLuint index, GLint size, GLenum type,
                             GLboolean normalized, uint offset){
    glBindBuffer(target, buffer);
    glEnableVertexAttribArray(index);
    glVertexAttribPointer(index, size, type, normalized, gltf.stride,
                          cast(void*)offset);
  }
}
// ----- camera ----------------------------------------------------------------
struct GL_glTFCamera {
  glTFCamera* gltf;
  this ( GL_glTFObject obj, ref glTFCamera _gltf ) {
    gltf = &_gltf;
  }
}
// ----- image -----------------------------------------------------------------
struct GL_glTFImage {
  glTFImage* gltf;
  this ( GL_glTFObject obj, ref glTFImage _gltf ) {
    gltf = &_gltf;
  }
}
// ----- material --------------------------------------------------------------
struct GL_glTFMaterial {
  glTFMaterial* gltf;
  GL_glTFTexture* colour_texture;
  this ( GL_glTFObject obj, ref glTFMaterial _gltf ) {
    gltf = &_gltf;
    gltf.material.visit!(
      (glTFMaterialNil mat){},
      (glTFMaterialPBRMetallicRoughness mat) {
        // if ( mat.base_colour_texture != "" ) {
          // colour_texture = 
        // }
      }
    );
  }

  GL_glTFTexture* RPrimary_Texture ( ) {
    return null;
    // gltf.material.visit!(
    //   (glTFMaterialNil mat){return null;},
    //   (glTFMaterialPBRMetallicRoughness mat) {
    //     if ( mat.base_colour_texture != "" )
    //       return GL_glTF
    //   }
    // );
  }
}
// ----- mesh ------------------------------------------------------------------
struct GL_glTFPrimitive {
  glTFPrimitive* gltf;
  GLuint render_vao, render_program, render_mode;
  bool has_index;
  uint render_length, render_gl_enum;

  this ( GL_glTFObject obj, ref glTFPrimitive _gltf ) {
    gltf = &_gltf;

    ShaderInfo sh_info;

    void Create_Buffer ( ref uint idx, glTFAttribute atr ) {
      auto accessor = gltf.RAccessor(atr);
      if ( accessor is null ) {
        sh_info.v_indices[atr] = -1;
        return;
      }
      auto buffer_view = obj.RGL_glTFBufferView(accessor.buffer_view);
      buffer_view.Vertex_Attrib_Pointer(
        idx, glTFType_Info(accessor.type).count,
        GL_glTFComponentType_Info(accessor.component_type).gl_type,
        GL_FALSE, accessor.offset);
      sh_info.v_indices[atr] = idx;
      idx += 1;
    }
    // -- generate buffers & fill vao data
    glGenVertexArrays(1, &render_vao);
    glBindVertexArray(render_vao);
    uint idx = 0; // count gl vertex attrib
    Create_Buffer(idx, glTFAttribute.Position);
    Create_Buffer(idx, glTFAttribute.Normal);
    Create_Buffer(idx, glTFAttribute.TexCoord0);
    Create_Buffer(idx, glTFAttribute.Colour0);
    has_index = gltf.Has_Index();


    // generate program/shaders
    sh_info.material = null;
    sh_info.has_colour_texture = false;
    if ( gltf.material !is null ) {
      sh_info.material = obj.RGL_glTFMaterial(gltf.material).gltf;
      sh_info.material.material.visit!(
        (glTFMaterialNil mat){},
        (glTFMaterialPBRMetallicRoughness mat) {
          if ( mat.base_colour_texture.Exists ) {
            sh_info.has_colour_texture = true;
            obj.RGL_glTFTexture(mat.base_colour_texture.texture).Bind(0, 10);
          }
        }
      );
    }
    // sh_info.has_texture = obj.RGL_glTFTexture(sh_info.m
    // -- operate on textures
    render_program = Generate_Shader(sh_info);

    // -- index buffer & misc data
    if ( has_index ) {
      auto acc = gltf.RAccessor(glTFAttribute.Index);
      render_gl_enum = GL_glTFComponentType_Info(acc.component_type).gl_type;
      render_length = acc.count;
      obj.RGL_glTFBufferView(acc.buffer_view).Bind();
    } else {
      render_length = gltf.RAccessor(glTFAttribute.Position).count;
    }
    render_mode = GL_glTFMode_Info(gltf.mode).gl_mode;
    glBindVertexArray(0);
    foreach ( i; 0 .. idx )
      glDisableVertexAttribArray(i);
  }

  // version(glTFViewer)
  void Render ( ref Matrix!(float, 4, 4) view_proj ) {
    glUseProgram(render_program);
    glBindVertexArray(render_vao);
    Matrix!(float, 4, 4) model = Matrix!(float, 4, 4).identity;
    glUniformMatrix4fv(0, 1, GL_TRUE, model.value_ptr);
    glUniformMatrix4fv(1, 1, GL_TRUE, view_proj.value_ptr);
    if ( !has_index ) glDrawArrays(render_mode, 0, render_length);
    else glDrawElements(render_mode, render_length, render_gl_enum, null);
  }
}
struct GL_glTFMesh {
  glTFMesh* gltf;

  GL_glTFPrimitive[] primitives;
  this ( GL_glTFObject obj, ref glTFMesh _gltf ) {
    gltf = &_gltf;
    primitives = gltf.primitives.map!(p => GL_glTFPrimitive(obj, p)).array;
  }

  // version(glTFViewer)
  void Render ( ref Matrix!(float, 4, 4) view_proj ) {
    primitives.each!(i => i.Render(view_proj));
  }
}
// ----- node ------------------------------------------------------------------
struct GL_glTFNode {
  glTFNode* gltf;
  this ( GL_glTFObject obj, ref glTFNode _gltf ) {
    gltf = &_gltf;
  }
}
// ----- sampler ---------------------------------------------------------------
struct GL_glTFSampler {
  glTFSampler* gltf;
  this ( GL_glTFObject obj, ref glTFSampler _gltf ) {
    gltf = &_gltf;
  }
}
// ----- scene -----------------------------------------------------------------
struct GL_glTFScene {
  glTFScene* gltf;
  this ( GL_glTFObject obj, ref glTFScene _gltf ) {
    gltf = &_gltf;
  }
}
// ----- skin ------------------------------------------------------------------
struct GL_glTFSkin {
  glTFSkin* gltf;
  this ( GL_glTFObject obj, ref glTFSkin _gltf ) {
    gltf = &_gltf;
  }
}
// ----- texture ---------------------------------------------------------------
struct GL_glTFTexture {
  glTFTexture* gltf;
  GLuint gl_texture;
  this ( GL_glTFObject obj, ref glTFTexture _gltf ) {
    gltf = &_gltf;
    glGenTextures(1, &gl_texture);
    glBindTexture(GL_TEXTURE_2D, gl_texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, gltf.image.width, gltf.image.height,
                 0, GL_RGBA, GL_UNSIGNED_BYTE, gltf.image.raw_data.ptr);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  }

  void Bind ( int idx, int bind_loc ) {
    glActiveTexture(GL_TEXTURE0 + idx);
    glBindTexture(GL_TEXTURE_2D, gl_texture);
    glUniform1i(bind_loc, idx);
  }
}
// ----- texture info ----------------------------------------------------------
struct GL_glTFMaterialTexture {
  glTFMaterialTexture* gltf;
  this ( GL_glTFObject obj, ref glTFMaterialTexture _gltf ) {
    gltf = &_gltf;
  }
}
