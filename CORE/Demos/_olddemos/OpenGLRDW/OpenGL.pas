
{*******************************************************}
{                                                       }
{       Borland Delphi Runtime Library                  }
{       OpenGL interface unit                           }
{                                                       }
{*******************************************************}

(*
** Copyright 1991-1993, Silicon Graphics, Inc.
** All Rights Reserved.
**
** This is UNPUBLISHED PROPRIETARY SOURCE CODE of Silicon Graphics, Inc.;
** the contents of this file may not be disclosed to third parties, copied or
** duplicated in any form, in whole or in part, without the prior written
** permission of Silicon Graphics, Inc.
**
** RESTRICTED RIGHTS LEGEND:
** Use, duplication or disclosure by the Government is subject to restrictions
** as set forth in subdivision (c)(1)(ii) of the Rights in Technical Data
** and Computer Software clause at DFARS 252.227-7013, and/or in similar or
** successor clauses in the FAR, DOD or NASA FAR Supplement. Unpublished -
** rights reserved under the Copyright Laws of the United States.
*)

unit OpenGL;

interface

uses Windows;

type
  {$EXTERNALSYM HGLRC}
  HGLRC = THandle;

type
  GLenum = Cardinal;
  {$EXTERNALSYM GLenum}
  GLboolean = BYTEBOOL;
  {$EXTERNALSYM GLboolean}
  GLbitfield = Cardinal;
  {$EXTERNALSYM GLbitfield}
  GLbyte = Shortint;   { signed char }
  {$EXTERNALSYM GLbyte}
  GLshort = SmallInt;
  {$EXTERNALSYM GLshort}
  GLint = Integer;
  {$EXTERNALSYM GLint}
  GLsizei = Integer;
  {$EXTERNALSYM GLsizei}
  GLubyte = Byte;
  {$EXTERNALSYM GLubyte}
  GLushort = Word;
  {$EXTERNALSYM GLushort}
  GLuint = Cardinal;
  {$EXTERNALSYM GLuint}
  GLfloat = Single;
  {$EXTERNALSYM GLfloat}
  GLclampf = Single;
  {$EXTERNALSYM GLclampf}
  GLdouble = Double;
  {$EXTERNALSYM GLdouble}
  GLclampd = Double;
  {$EXTERNALSYM GLclampd}

  PGLBoolean = ^GLBoolean;
  PGLByte = ^GLByte;
  PGLShort = ^GLShort;
  PGLInt = ^GLInt;
  PGLSizei = ^GLSizei;
  PGLubyte = ^GLubyte;
  PGLushort = ^GLushort;
  PGLuint = ^GLuint;
  PGLclampf = ^GLclampf;
  PGLfloat =  ^GLFloat;
  PGLdouble = ^GLDouble;
  PGLclampd = ^GLclampd;

  TGLArrayf4 = array [0..3] of GLFloat;
  TGLArrayf3 = array [0..2] of GLFloat;
  TGLArrayi4 = array [0..3] of GLint;
  {...}

{*************************************************************}

const
{ AttribMask }
  GL_CURRENT_BIT                      = $00000001;
  {$EXTERNALSYM GL_CURRENT_BIT}
  GL_POINT_BIT                        = $00000002;
  {$EXTERNALSYM GL_POINT_BIT}
  GL_LINE_BIT                         = $00000004;
  {$EXTERNALSYM GL_LINE_BIT}
  GL_POLYGON_BIT                      = $00000008;
  {$EXTERNALSYM GL_POLYGON_BIT}
  GL_POLYGON_STIPPLE_BIT              = $00000010;
  {$EXTERNALSYM GL_POLYGON_STIPPLE_BIT}
  GL_PIXEL_MODE_BIT                   = $00000020;
  {$EXTERNALSYM GL_PIXEL_MODE_BIT}
  GL_LIGHTING_BIT                     = $00000040;
  {$EXTERNALSYM GL_LIGHTING_BIT}
  GL_FOG_BIT                          = $00000080;
  {$EXTERNALSYM GL_FOG_BIT}
  GL_DEPTH_BUFFER_BIT                 = $00000100;
  {$EXTERNALSYM GL_DEPTH_BUFFER_BIT}
  GL_ACCUM_BUFFER_BIT                 = $00000200;
  {$EXTERNALSYM GL_ACCUM_BUFFER_BIT}
  GL_STENCIL_BUFFER_BIT               = $00000400;
  {$EXTERNALSYM GL_STENCIL_BUFFER_BIT}
  GL_VIEWPORT_BIT                     = $00000800;
  {$EXTERNALSYM GL_VIEWPORT_BIT}
  GL_TRANSFORM_BIT                    = $00001000;
  {$EXTERNALSYM GL_TRANSFORM_BIT}
  GL_ENABLE_BIT                       = $00002000;
  {$EXTERNALSYM GL_ENABLE_BIT}
  GL_COLOR_BUFFER_BIT                 = $00004000;
  {$EXTERNALSYM GL_COLOR_BUFFER_BIT}
  GL_HINT_BIT                         = $00008000;
  {$EXTERNALSYM GL_HINT_BIT}
  GL_EVAL_BIT                         = $00010000;
  {$EXTERNALSYM GL_EVAL_BIT}
  GL_LIST_BIT                         = $00020000;
  {$EXTERNALSYM GL_LIST_BIT}
  GL_TEXTURE_BIT                      = $00040000;
  {$EXTERNALSYM GL_TEXTURE_BIT}
  GL_SCISSOR_BIT                      = $00080000;
  {$EXTERNALSYM GL_SCISSOR_BIT}
  GL_ALL_ATTRIB_BITS                  = $000fffff;
  {$EXTERNALSYM GL_ALL_ATTRIB_BITS}

{ ClearBufferMask }
{      GL_COLOR_BUFFER_BIT }
{      GL_ACCUM_BUFFER_BIT }
{      GL_STENCIL_BUFFER_BIT }
{      GL_DEPTH_BUFFER_BIT }

{ Boolean }
  GL_FALSE                            = Boolean(0);
  {$EXTERNALSYM GL_FALSE}
  GL_TRUE                             = Boolean(1);
  {$EXTERNALSYM GL_TRUE}

{ BeginMode }
  GL_POINTS                           = $0000    ;
  {$EXTERNALSYM GL_POINTS}
  GL_LINES                            = $0001    ;
  {$EXTERNALSYM GL_LINES}
  GL_LINE_LOOP                        = $0002    ;
  {$EXTERNALSYM GL_LINE_LOOP}
  GL_LINE_STRIP                       = $0003    ;
  {$EXTERNALSYM GL_LINE_STRIP}
  GL_TRIANGLES                        = $0004    ;
  {$EXTERNALSYM GL_TRIANGLES}
  GL_TRIANGLE_STRIP                   = $0005    ;
  {$EXTERNALSYM GL_TRIANGLE_STRIP}
  GL_TRIANGLE_FAN                     = $0006    ;
  {$EXTERNALSYM GL_TRIANGLE_FAN}
  GL_QUADS                            = $0007    ;
  {$EXTERNALSYM GL_QUADS}
  GL_QUAD_STRIP                       = $0008    ;
  {$EXTERNALSYM GL_QUAD_STRIP}
  GL_POLYGON                          = $0009    ;
  {$EXTERNALSYM GL_POLYGON}

{ AccumOp }
  GL_ACCUM                            = $0100;
  {$EXTERNALSYM GL_ACCUM}
  GL_LOAD                             = $0101;
  {$EXTERNALSYM GL_LOAD}
  GL_RETURN                           = $0102;
  {$EXTERNALSYM GL_RETURN}
  GL_MULT                             = $0103;
  {$EXTERNALSYM GL_MULT}
  GL_ADD                              = $0104;
  {$EXTERNALSYM GL_ADD}

{ AlphaFunction }
  GL_NEVER                            = $0200;
  {$EXTERNALSYM GL_NEVER}
  GL_LESS                             = $0201;
  {$EXTERNALSYM GL_LESS}
  GL_EQUAL                            = $0202;
  {$EXTERNALSYM GL_EQUAL}
  GL_LEQUAL                           = $0203;
  {$EXTERNALSYM GL_LEQUAL}
  GL_GREATER                          = $0204;
  {$EXTERNALSYM GL_GREATER}
  GL_NOTEQUAL                         = $0205;
  {$EXTERNALSYM GL_NOTEQUAL}
  GL_GEQUAL                           = $0206;
  {$EXTERNALSYM GL_GEQUAL}
  GL_ALWAYS                           = $0207;
  {$EXTERNALSYM GL_ALWAYS}

{ BlendingFactorDest }
  GL_ZERO                             = 0;
  {$EXTERNALSYM GL_ZERO}
  GL_ONE                              = 1;
  {$EXTERNALSYM GL_ONE}
  GL_SRC_COLOR                        = $0300;
  {$EXTERNALSYM GL_SRC_COLOR}
  GL_ONE_MINUS_SRC_COLOR              = $0301;
  {$EXTERNALSYM GL_ONE_MINUS_SRC_COLOR}
  GL_SRC_ALPHA                        = $0302;
  {$EXTERNALSYM GL_SRC_ALPHA}
  GL_ONE_MINUS_SRC_ALPHA              = $0303;
  {$EXTERNALSYM GL_ONE_MINUS_SRC_ALPHA}
  GL_DST_ALPHA                        = $0304;
  {$EXTERNALSYM GL_DST_ALPHA}
  GL_ONE_MINUS_DST_ALPHA              = $0305;
  {$EXTERNALSYM GL_ONE_MINUS_DST_ALPHA}

{ BlendingFactorSrc }
{      GL_ZERO }
{      GL_ONE }
  GL_DST_COLOR                        = $0306;
  {$EXTERNALSYM GL_DST_COLOR}
  GL_ONE_MINUS_DST_COLOR              = $0307;
  {$EXTERNALSYM GL_ONE_MINUS_DST_COLOR}
  GL_SRC_ALPHA_SATURATE               = $0308;
  {$EXTERNALSYM GL_SRC_ALPHA_SATURATE}
{      GL_SRC_ALPHA }
{      GL_ONE_MINUS_SRC_ALPHA }
{      GL_DST_ALPHA }
{      GL_ONE_MINUS_DST_ALPHA }

{ BlendingMode }
{      GL_LOGIC_OP }

{ ColorMaterialFace }
{      GL_FRONT }
{      GL_BACK }
{      GL_FRONT_AND_BACK }

{ ColorMaterialParameter }
{      GL_AMBIENT }
{      GL_DIFFUSE }
{      GL_SPECULAR }
{      GL_EMISSION }
{      GL_AMBIENT_AND_DIFFUSE }

{ CullFaceMode }
{      GL_FRONT }
{      GL_BACK }
{      GL_FRONT_AND_BACK }

{ DepthFunction }
{      GL_NEVER }
{      GL_LESS }
{      GL_EQUAL }
{      GL_LEQUAL }
{      GL_GREATER }
{      GL_NOTEQUAL }
{      GL_GEQUAL }
{      GL_ALWAYS }

{ DrawBufferMode }
  GL_NONE                             = 0;
  {$EXTERNALSYM GL_NONE}
  GL_FRONT_LEFT                       = $0400;
  {$EXTERNALSYM GL_FRONT_LEFT}
  GL_FRONT_RIGHT                      = $0401;
  {$EXTERNALSYM GL_FRONT_RIGHT}
  GL_BACK_LEFT                        = $0402;
  {$EXTERNALSYM GL_BACK_LEFT}
  GL_BACK_RIGHT                       = $0403;
  {$EXTERNALSYM GL_BACK_RIGHT}
  GL_FRONT                            = $0404;
  {$EXTERNALSYM GL_FRONT}
  GL_BACK                             = $0405;
  {$EXTERNALSYM GL_BACK}
  GL_LEFT                             = $0406;
  {$EXTERNALSYM GL_LEFT}
  GL_RIGHT                            = $0407;
  {$EXTERNALSYM GL_RIGHT}
  GL_FRONT_AND_BACK                   = $0408;
  {$EXTERNALSYM GL_FRONT_AND_BACK}
  GL_AUX0                             = $0409;
  {$EXTERNALSYM GL_AUX0}
  GL_AUX1                             = $040A;
  {$EXTERNALSYM GL_AUX1}
  GL_AUX2                             = $040B;
  {$EXTERNALSYM GL_AUX2}
  GL_AUX3                             = $040C;
  {$EXTERNALSYM GL_AUX3}

{ ErrorCode }
  GL_NO_ERROR                         = 0;
  {$EXTERNALSYM GL_NO_ERROR}
  GL_INVALID_ENUM                     = $0500;
  {$EXTERNALSYM GL_INVALID_ENUM}
  GL_INVALID_VALUE                    = $0501;
  {$EXTERNALSYM GL_INVALID_VALUE}
  GL_INVALID_OPERATION                = $0502;
  {$EXTERNALSYM GL_INVALID_OPERATION}
  GL_STACK_OVERFLOW                   = $0503;
  {$EXTERNALSYM GL_STACK_OVERFLOW}
  GL_STACK_UNDERFLOW                  = $0504;
  {$EXTERNALSYM GL_STACK_UNDERFLOW}
  GL_OUT_OF_MEMORY                    = $0505;
  {$EXTERNALSYM GL_OUT_OF_MEMORY}

{ FeedBackMode }
  GL_2D                               = $0600;
  {$EXTERNALSYM GL_2D}
  GL_3D                               = $0601;
  {$EXTERNALSYM GL_3D}
  GL_3D_COLOR                         = $0602;
  {$EXTERNALSYM GL_3D_COLOR}
  GL_3D_COLOR_TEXTURE                 = $0603;
  {$EXTERNALSYM GL_3D_COLOR_TEXTURE}
  GL_4D_COLOR_TEXTURE                 = $0604;
  {$EXTERNALSYM GL_4D_COLOR_TEXTURE}

{ FeedBackToken }
  GL_PASS_THROUGH_TOKEN               = $0700;
  {$EXTERNALSYM GL_PASS_THROUGH_TOKEN}
  GL_POINT_TOKEN                      = $0701;
  {$EXTERNALSYM GL_POINT_TOKEN}
  GL_LINE_TOKEN                       = $0702;
  {$EXTERNALSYM GL_LINE_TOKEN}
  GL_POLYGON_TOKEN                    = $0703;
  {$EXTERNALSYM GL_POLYGON_TOKEN}
  GL_BITMAP_TOKEN                     = $0704;
  {$EXTERNALSYM GL_BITMAP_TOKEN}
  GL_DRAW_PIXEL_TOKEN                 = $0705;
  {$EXTERNALSYM GL_DRAW_PIXEL_TOKEN}
  GL_COPY_PIXEL_TOKEN                 = $0706;
  {$EXTERNALSYM GL_COPY_PIXEL_TOKEN}
  GL_LINE_RESET_TOKEN                 = $0707;
  {$EXTERNALSYM GL_LINE_RESET_TOKEN}

{ FogMode }
{      GL_LINEAR }
  GL_EXP                              = $0800;
  {$EXTERNALSYM GL_EXP}
  GL_EXP2                             = $0801;
  {$EXTERNALSYM GL_EXP2}

{ FogParameter }
{      GL_FOG_COLOR }
{      GL_FOG_DENSITY }
{      GL_FOG_END }
{      GL_FOG_INDEX }
{      GL_FOG_MODE }
{      GL_FOG_START }

{ FrontFaceDirection }
  GL_CW                               = $0900;
  {$EXTERNALSYM GL_CW}
  GL_CCW                              = $0901;
  {$EXTERNALSYM GL_CCW}

{ GetMapTarget }
  GL_COEFF                            = $0A00;
  {$EXTERNALSYM GL_COEFF}
  GL_ORDER                            = $0A01;
  {$EXTERNALSYM GL_ORDER}
  GL_DOMAIN                           = $0A02;
  {$EXTERNALSYM GL_DOMAIN}

{ GetPixelMap }
  GL_PIXEL_MAP_I_TO_I                 = $0C70;
  {$EXTERNALSYM GL_PIXEL_MAP_I_TO_I}
  GL_PIXEL_MAP_S_TO_S                 = $0C71;
  {$EXTERNALSYM GL_PIXEL_MAP_S_TO_S}
  GL_PIXEL_MAP_I_TO_R                 = $0C72;
  {$EXTERNALSYM GL_PIXEL_MAP_I_TO_R}
  GL_PIXEL_MAP_I_TO_G                 = $0C73;
  {$EXTERNALSYM GL_PIXEL_MAP_I_TO_G}
  GL_PIXEL_MAP_I_TO_B                 = $0C74;
  {$EXTERNALSYM GL_PIXEL_MAP_I_TO_B}
  GL_PIXEL_MAP_I_TO_A                 = $0C75;
  {$EXTERNALSYM GL_PIXEL_MAP_I_TO_A}
  GL_PIXEL_MAP_R_TO_R                 = $0C76;
  {$EXTERNALSYM GL_PIXEL_MAP_R_TO_R}
  GL_PIXEL_MAP_G_TO_G                 = $0C77;
  {$EXTERNALSYM GL_PIXEL_MAP_G_TO_G}
  GL_PIXEL_MAP_B_TO_B                 = $0C78;
  {$EXTERNALSYM GL_PIXEL_MAP_B_TO_B}
  GL_PIXEL_MAP_A_TO_A                 = $0C79;
  {$EXTERNALSYM GL_PIXEL_MAP_A_TO_A}

{ GetTarget }
  GL_CURRENT_COLOR                    = $0B00;
  {$EXTERNALSYM GL_CURRENT_COLOR}
  GL_CURRENT_INDEX                    = $0B01;
  {$EXTERNALSYM GL_CURRENT_INDEX}
  GL_CURRENT_NORMAL                   = $0B02;
  {$EXTERNALSYM GL_CURRENT_NORMAL}
  GL_CURRENT_TEXTURE_COORDS           = $0B03;
  {$EXTERNALSYM GL_CURRENT_TEXTURE_COORDS}
  GL_CURRENT_RASTER_COLOR             = $0B04;
  {$EXTERNALSYM GL_CURRENT_RASTER_COLOR}
  GL_CURRENT_RASTER_INDEX             = $0B05;
  {$EXTERNALSYM GL_CURRENT_RASTER_INDEX}
  GL_CURRENT_RASTER_TEXTURE_COORDS    = $0B06;
  {$EXTERNALSYM GL_CURRENT_RASTER_TEXTURE_COORDS}
  GL_CURRENT_RASTER_POSITION          = $0B07;
  {$EXTERNALSYM GL_CURRENT_RASTER_POSITION}
  GL_CURRENT_RASTER_POSITION_VALID    = $0B08;
  {$EXTERNALSYM GL_CURRENT_RASTER_POSITION_VALID}
  GL_CURRENT_RASTER_DISTANCE          = $0B09;
  {$EXTERNALSYM GL_CURRENT_RASTER_DISTANCE}
  GL_POINT_SMOOTH                     = $0B10;
  {$EXTERNALSYM GL_POINT_SMOOTH}
  GL_POINT_SIZE                       = $0B11;
  {$EXTERNALSYM GL_POINT_SIZE}
  GL_POINT_SIZE_RANGE                 = $0B12;
  {$EXTERNALSYM GL_POINT_SIZE_RANGE}
  GL_POINT_SIZE_GRANULARITY           = $0B13;
  {$EXTERNALSYM GL_POINT_SIZE_GRANULARITY}
  GL_LINE_SMOOTH                      = $0B20;
  {$EXTERNALSYM GL_LINE_SMOOTH}
  GL_LINE_WIDTH                       = $0B21;
  {$EXTERNALSYM GL_LINE_WIDTH}
  GL_LINE_WIDTH_RANGE                 = $0B22;
  {$EXTERNALSYM GL_LINE_WIDTH_RANGE}
  GL_LINE_WIDTH_GRANULARITY           = $0B23;
  {$EXTERNALSYM GL_LINE_WIDTH_GRANULARITY}
  GL_LINE_STIPPLE                     = $0B24;
  {$EXTERNALSYM GL_LINE_STIPPLE}
  GL_LINE_STIPPLE_PATTERN             = $0B25;
  {$EXTERNALSYM GL_LINE_STIPPLE_PATTERN}
  GL_LINE_STIPPLE_REPEAT              = $0B26;
  {$EXTERNALSYM GL_LINE_STIPPLE_REPEAT}
  GL_LIST_MODE                        = $0B30;
  {$EXTERNALSYM GL_LIST_MODE}
  GL_MAX_LIST_NESTING                 = $0B31;
  {$EXTERNALSYM GL_MAX_LIST_NESTING}
  GL_LIST_BASE                        = $0B32;
  {$EXTERNALSYM GL_LIST_BASE}
  GL_LIST_INDEX                       = $0B33;
  {$EXTERNALSYM GL_LIST_INDEX}
  GL_POLYGON_MODE                     = $0B40;
  {$EXTERNALSYM GL_POLYGON_MODE}
  GL_POLYGON_SMOOTH                   = $0B41;
  {$EXTERNALSYM GL_POLYGON_SMOOTH}
  GL_POLYGON_STIPPLE                  = $0B42;
  {$EXTERNALSYM GL_POLYGON_STIPPLE}
  GL_EDGE_FLAG                        = $0B43;
  {$EXTERNALSYM GL_EDGE_FLAG}
  GL_CULL_FACE                        = $0B44;
  {$EXTERNALSYM GL_CULL_FACE}
  GL_CULL_FACE_MODE                   = $0B45;
  {$EXTERNALSYM GL_CULL_FACE_MODE}
  GL_FRONT_FACE                       = $0B46;
  {$EXTERNALSYM GL_FRONT_FACE}
  GL_LIGHTING                         = $0B50;
  {$EXTERNALSYM GL_LIGHTING}
  GL_LIGHT_MODEL_LOCAL_VIEWER         = $0B51;
  {$EXTERNALSYM GL_LIGHT_MODEL_LOCAL_VIEWER}
  GL_LIGHT_MODEL_TWO_SIDE             = $0B52;
  {$EXTERNALSYM GL_LIGHT_MODEL_TWO_SIDE}
  GL_LIGHT_MODEL_AMBIENT              = $0B53;
  {$EXTERNALSYM GL_LIGHT_MODEL_AMBIENT}
  GL_SHADE_MODEL                      = $0B54;
  {$EXTERNALSYM GL_SHADE_MODEL}
  GL_COLOR_MATERIAL_FACE              = $0B55;
  {$EXTERNALSYM GL_COLOR_MATERIAL_FACE}
  GL_COLOR_MATERIAL_PARAMETER         = $0B56;
  {$EXTERNALSYM GL_COLOR_MATERIAL_PARAMETER}
  GL_COLOR_MATERIAL                   = $0B57;
  {$EXTERNALSYM GL_COLOR_MATERIAL}
  GL_FOG                              = $0B60;
  {$EXTERNALSYM GL_FOG}
  GL_FOG_INDEX                        = $0B61;
  {$EXTERNALSYM GL_FOG_INDEX}
  GL_FOG_DENSITY                      = $0B62;
  {$EXTERNALSYM GL_FOG_DENSITY}
  GL_FOG_START                        = $0B63;
  {$EXTERNALSYM GL_FOG_START}
  GL_FOG_END                          = $0B64;
  {$EXTERNALSYM GL_FOG_END}
  GL_FOG_MODE                         = $0B65;
  {$EXTERNALSYM GL_FOG_MODE}
  GL_FOG_COLOR                        = $0B66;
  {$EXTERNALSYM GL_FOG_COLOR}
  GL_DEPTH_RANGE                      = $0B70;
  {$EXTERNALSYM GL_DEPTH_RANGE}
  GL_DEPTH_TEST                       = $0B71;
  {$EXTERNALSYM GL_DEPTH_TEST}
  GL_DEPTH_WRITEMASK                  = $0B72;
  {$EXTERNALSYM GL_DEPTH_WRITEMASK}
  GL_DEPTH_CLEAR_VALUE                = $0B73;
  {$EXTERNALSYM GL_DEPTH_CLEAR_VALUE}
  GL_DEPTH_FUNC                       = $0B74;
  {$EXTERNALSYM GL_DEPTH_FUNC}
  GL_ACCUM_CLEAR_VALUE                = $0B80;
  {$EXTERNALSYM GL_ACCUM_CLEAR_VALUE}
  GL_STENCIL_TEST                     = $0B90;
  {$EXTERNALSYM GL_STENCIL_TEST}
  GL_STENCIL_CLEAR_VALUE              = $0B91;
  {$EXTERNALSYM GL_STENCIL_CLEAR_VALUE}
  GL_STENCIL_FUNC                     = $0B92;
  {$EXTERNALSYM GL_STENCIL_FUNC}
  GL_STENCIL_VALUE_MASK               = $0B93;
  {$EXTERNALSYM GL_STENCIL_VALUE_MASK}
  GL_STENCIL_FAIL                     = $0B94;
  {$EXTERNALSYM GL_STENCIL_FAIL}
  GL_STENCIL_PASS_DEPTH_FAIL          = $0B95;
  {$EXTERNALSYM GL_STENCIL_PASS_DEPTH_FAIL}
  GL_STENCIL_PASS_DEPTH_PASS          = $0B96;
  {$EXTERNALSYM GL_STENCIL_PASS_DEPTH_PASS}
  GL_STENCIL_REF                      = $0B97;
  {$EXTERNALSYM GL_STENCIL_REF}
  GL_STENCIL_WRITEMASK                = $0B98;
  {$EXTERNALSYM GL_STENCIL_WRITEMASK}
  GL_MATRIX_MODE                      = $0BA0;
  {$EXTERNALSYM GL_MATRIX_MODE}
  GL_NORMALIZE                        = $0BA1;
  {$EXTERNALSYM GL_NORMALIZE}
  GL_VIEWPORT                         = $0BA2;
  {$EXTERNALSYM GL_VIEWPORT}
  GL_MODELVIEW_STACK_DEPTH            = $0BA3;
  {$EXTERNALSYM GL_MODELVIEW_STACK_DEPTH}
  GL_PROJECTION_STACK_DEPTH           = $0BA4;
  {$EXTERNALSYM GL_PROJECTION_STACK_DEPTH}
  GL_TEXTURE_STACK_DEPTH              = $0BA5;
  {$EXTERNALSYM GL_TEXTURE_STACK_DEPTH}
  GL_MODELVIEW_MATRIX                 = $0BA6;
  {$EXTERNALSYM GL_MODELVIEW_MATRIX}
  GL_PROJECTION_MATRIX                = $0BA7;
  {$EXTERNALSYM GL_PROJECTION_MATRIX}
  GL_TEXTURE_MATRIX                   = $0BA8;
  {$EXTERNALSYM GL_TEXTURE_MATRIX}
  GL_ATTRIB_STACK_DEPTH               = $0BB0;
  {$EXTERNALSYM GL_ATTRIB_STACK_DEPTH}
  GL_ALPHA_TEST                       = $0BC0;
  {$EXTERNALSYM GL_ALPHA_TEST}
  GL_ALPHA_TEST_FUNC                  = $0BC1;
  {$EXTERNALSYM GL_ALPHA_TEST_FUNC}
  GL_ALPHA_TEST_REF                   = $0BC2;
  {$EXTERNALSYM GL_ALPHA_TEST_REF}
  GL_DITHER                           = $0BD0;
  {$EXTERNALSYM GL_DITHER}
  GL_BLEND_DST                        = $0BE0;
  {$EXTERNALSYM GL_BLEND_DST}
  GL_BLEND_SRC                        = $0BE1;
  {$EXTERNALSYM GL_BLEND_SRC}
  GL_BLEND                            = $0BE2;
  {$EXTERNALSYM GL_BLEND}
  GL_LOGIC_OP_MODE                    = $0BF0;
  {$EXTERNALSYM GL_LOGIC_OP_MODE}
  GL_LOGIC_OP                         = $0BF1;
  {$EXTERNALSYM GL_LOGIC_OP}
  GL_AUX_BUFFERS                      = $0C00;
  {$EXTERNALSYM GL_AUX_BUFFERS}
  GL_DRAW_BUFFER                      = $0C01;
  {$EXTERNALSYM GL_DRAW_BUFFER}
  GL_READ_BUFFER                      = $0C02;
  {$EXTERNALSYM GL_READ_BUFFER}
  GL_SCISSOR_BOX                      = $0C10;
  {$EXTERNALSYM GL_SCISSOR_BOX}
  GL_SCISSOR_TEST                     = $0C11;
  {$EXTERNALSYM GL_SCISSOR_TEST}
  GL_INDEX_CLEAR_VALUE                = $0C20;
  {$EXTERNALSYM GL_INDEX_CLEAR_VALUE}
  GL_INDEX_WRITEMASK                  = $0C21;
  {$EXTERNALSYM GL_INDEX_WRITEMASK}
  GL_COLOR_CLEAR_VALUE                = $0C22;
  {$EXTERNALSYM GL_COLOR_CLEAR_VALUE}
  GL_COLOR_WRITEMASK                  = $0C23;
  {$EXTERNALSYM GL_COLOR_WRITEMASK}
  GL_INDEX_MODE                       = $0C30;
  {$EXTERNALSYM GL_INDEX_MODE}
  GL_RGBA_MODE                        = $0C31;
  {$EXTERNALSYM GL_RGBA_MODE}
  GL_DOUBLEBUFFER                     = $0C32;
  {$EXTERNALSYM GL_DOUBLEBUFFER}
  GL_STEREO                           = $0C33;
  {$EXTERNALSYM GL_STEREO}
  GL_RENDER_MODE                      = $0C40;
  {$EXTERNALSYM GL_RENDER_MODE}
  GL_PERSPECTIVE_CORRECTION_HINT      = $0C50;
  {$EXTERNALSYM GL_PERSPECTIVE_CORRECTION_HINT}
  GL_POINT_SMOOTH_HINT                = $0C51;
  {$EXTERNALSYM GL_POINT_SMOOTH_HINT}
  GL_LINE_SMOOTH_HINT                 = $0C52;
  {$EXTERNALSYM GL_LINE_SMOOTH_HINT}
  GL_POLYGON_SMOOTH_HINT              = $0C53;
  {$EXTERNALSYM GL_POLYGON_SMOOTH_HINT}
  GL_FOG_HINT                         = $0C54;
  {$EXTERNALSYM GL_FOG_HINT}
  GL_TEXTURE_GEN_S                    = $0C60;
  {$EXTERNALSYM GL_TEXTURE_GEN_S}
  GL_TEXTURE_GEN_T                    = $0C61;
  {$EXTERNALSYM GL_TEXTURE_GEN_T}
  GL_TEXTURE_GEN_R                    = $0C62;
  {$EXTERNALSYM GL_TEXTURE_GEN_R}
  GL_TEXTURE_GEN_Q                    = $0C63;
  {$EXTERNALSYM GL_TEXTURE_GEN_Q}
  GL_PIXEL_MAP_I_TO_I_SIZE            = $0CB0;
  {$EXTERNALSYM GL_PIXEL_MAP_I_TO_I_SIZE}
  GL_PIXEL_MAP_S_TO_S_SIZE            = $0CB1;
  {$EXTERNALSYM GL_PIXEL_MAP_S_TO_S_SIZE}
  GL_PIXEL_MAP_I_TO_R_SIZE            = $0CB2;
  {$EXTERNALSYM GL_PIXEL_MAP_I_TO_R_SIZE}
  GL_PIXEL_MAP_I_TO_G_SIZE            = $0CB3;
  {$EXTERNALSYM GL_PIXEL_MAP_I_TO_G_SIZE}
  GL_PIXEL_MAP_I_TO_B_SIZE            = $0CB4;
  {$EXTERNALSYM GL_PIXEL_MAP_I_TO_B_SIZE}
  GL_PIXEL_MAP_I_TO_A_SIZE            = $0CB5;
  {$EXTERNALSYM GL_PIXEL_MAP_I_TO_A_SIZE}
  GL_PIXEL_MAP_R_TO_R_SIZE            = $0CB6;
  {$EXTERNALSYM GL_PIXEL_MAP_R_TO_R_SIZE}
  GL_PIXEL_MAP_G_TO_G_SIZE            = $0CB7;
  {$EXTERNALSYM GL_PIXEL_MAP_G_TO_G_SIZE}
  GL_PIXEL_MAP_B_TO_B_SIZE            = $0CB8;
  {$EXTERNALSYM GL_PIXEL_MAP_B_TO_B_SIZE}
  GL_PIXEL_MAP_A_TO_A_SIZE            = $0CB9;
  {$EXTERNALSYM GL_PIXEL_MAP_A_TO_A_SIZE}
  GL_UNPACK_SWAP_BYTES                = $0CF0;
  {$EXTERNALSYM GL_UNPACK_SWAP_BYTES}
  GL_UNPACK_LSB_FIRST                 = $0CF1;
  {$EXTERNALSYM GL_UNPACK_LSB_FIRST}
  GL_UNPACK_ROW_LENGTH                = $0CF2;
  {$EXTERNALSYM GL_UNPACK_ROW_LENGTH}
  GL_UNPACK_SKIP_ROWS                 = $0CF3;
  {$EXTERNALSYM GL_UNPACK_SKIP_ROWS}
  GL_UNPACK_SKIP_PIXELS               = $0CF4;
  {$EXTERNALSYM GL_UNPACK_SKIP_PIXELS}
  GL_UNPACK_ALIGNMENT                 = $0CF5;
  {$EXTERNALSYM GL_UNPACK_ALIGNMENT}
  GL_PACK_SWAP_BYTES                  = $0D00;
  {$EXTERNALSYM GL_PACK_SWAP_BYTES}
  GL_PACK_LSB_FIRST                   = $0D01;
  {$EXTERNALSYM GL_PACK_LSB_FIRST}
  GL_PACK_ROW_LENGTH                  = $0D02;
  {$EXTERNALSYM GL_PACK_ROW_LENGTH}
  GL_PACK_SKIP_ROWS                   = $0D03;
  {$EXTERNALSYM GL_PACK_SKIP_ROWS}
  GL_PACK_SKIP_PIXELS                 = $0D04;
  {$EXTERNALSYM GL_PACK_SKIP_PIXELS}
  GL_PACK_ALIGNMENT                   = $0D05;
  {$EXTERNALSYM GL_PACK_ALIGNMENT}
  GL_MAP_COLOR                        = $0D10;
  {$EXTERNALSYM GL_MAP_COLOR}
  GL_MAP_STENCIL                      = $0D11;
  {$EXTERNALSYM GL_MAP_STENCIL}
  GL_INDEX_SHIFT                      = $0D12;
  {$EXTERNALSYM GL_INDEX_SHIFT}
  GL_INDEX_OFFSET                     = $0D13;
  {$EXTERNALSYM GL_INDEX_OFFSET}
  GL_RED_SCALE                        = $0D14;
  {$EXTERNALSYM GL_RED_SCALE}
  GL_RED_BIAS                         = $0D15;
  {$EXTERNALSYM GL_RED_BIAS}
  GL_ZOOM_X                           = $0D16;
  {$EXTERNALSYM GL_ZOOM_X}
  GL_ZOOM_Y                           = $0D17;
  {$EXTERNALSYM GL_ZOOM_Y}
  GL_GREEN_SCALE                      = $0D18;
  {$EXTERNALSYM GL_GREEN_SCALE}
  GL_GREEN_BIAS                       = $0D19;
  {$EXTERNALSYM GL_GREEN_BIAS}
  GL_BLUE_SCALE                       = $0D1A;
  {$EXTERNALSYM GL_BLUE_SCALE}
  GL_BLUE_BIAS                        = $0D1B;
  {$EXTERNALSYM GL_BLUE_BIAS}
  GL_ALPHA_SCALE                      = $0D1C;
  {$EXTERNALSYM GL_ALPHA_SCALE}
  GL_ALPHA_BIAS                       = $0D1D;
  {$EXTERNALSYM GL_ALPHA_BIAS}
  GL_DEPTH_SCALE                      = $0D1E;
  {$EXTERNALSYM GL_DEPTH_SCALE}
  GL_DEPTH_BIAS                       = $0D1F;
  {$EXTERNALSYM GL_DEPTH_BIAS}
  GL_MAX_EVAL_ORDER                   = $0D30;
  {$EXTERNALSYM GL_MAX_EVAL_ORDER}
  GL_MAX_LIGHTS                       = $0D31;
  {$EXTERNALSYM GL_MAX_EVAL_ORDER}
  GL_MAX_CLIP_PLANES                  = $0D32;
  {$EXTERNALSYM GL_MAX_CLIP_PLANES}
  GL_MAX_TEXTURE_SIZE                 = $0D33;
  {$EXTERNALSYM GL_MAX_TEXTURE_SIZE}
  GL_MAX_PIXEL_MAP_TABLE              = $0D34;
  {$EXTERNALSYM GL_MAX_PIXEL_MAP_TABLE}
  GL_MAX_ATTRIB_STACK_DEPTH           = $0D35;
  {$EXTERNALSYM GL_MAX_ATTRIB_STACK_DEPTH}
  GL_MAX_MODELVIEW_STACK_DEPTH        = $0D36;
  {$EXTERNALSYM GL_MAX_MODELVIEW_STACK_DEPTH}
  GL_MAX_NAME_STACK_DEPTH             = $0D37;
  {$EXTERNALSYM GL_MAX_NAME_STACK_DEPTH}
  GL_MAX_PROJECTION_STACK_DEPTH       = $0D38;
  {$EXTERNALSYM GL_MAX_PROJECTION_STACK_DEPTH}
  GL_MAX_TEXTURE_STACK_DEPTH          = $0D39;
  {$EXTERNALSYM GL_MAX_TEXTURE_STACK_DEPTH}
  GL_MAX_VIEWPORT_DIMS                = $0D3A;
  {$EXTERNALSYM GL_MAX_VIEWPORT_DIMS}
  GL_SUBPIXEL_BITS                    = $0D50;
  {$EXTERNALSYM GL_SUBPIXEL_BITS}
  GL_INDEX_BITS                       = $0D51;
  {$EXTERNALSYM GL_INDEX_BITS}
  GL_RED_BITS                         = $0D52;
  {$EXTERNALSYM GL_RED_BITS}
  GL_GREEN_BITS                       = $0D53;
  {$EXTERNALSYM GL_GREEN_BITS}
  GL_BLUE_BITS                        = $0D54;
  {$EXTERNALSYM GL_BLUE_BITS}
  GL_ALPHA_BITS                       = $0D55;
  {$EXTERNALSYM GL_ALPHA_BITS}
  GL_DEPTH_BITS                       = $0D56;
  {$EXTERNALSYM GL_DEPTH_BITS}
  GL_STENCIL_BITS                     = $0D57;
  {$EXTERNALSYM GL_STENCIL_BITS}
  GL_ACCUM_RED_BITS                   = $0D58;
  {$EXTERNALSYM GL_ACCUM_RED_BITS}
  GL_ACCUM_GREEN_BITS                 = $0D59;
  {$EXTERNALSYM GL_ACCUM_GREEN_BITS}
  GL_ACCUM_BLUE_BITS                  = $0D5A;
  {$EXTERNALSYM GL_ACCUM_BLUE_BITS}
  GL_ACCUM_ALPHA_BITS                 = $0D5B;
  {$EXTERNALSYM GL_ACCUM_ALPHA_BITS}
  GL_NAME_STACK_DEPTH                 = $0D70;
  {$EXTERNALSYM GL_NAME_STACK_DEPTH}
  GL_AUTO_NORMAL                      = $0D80;
  {$EXTERNALSYM GL_AUTO_NORMAL}
  GL_MAP1_COLOR_4                     = $0D90;
  {$EXTERNALSYM GL_MAP1_COLOR_4}
  GL_MAP1_INDEX                       = $0D91;
  {$EXTERNALSYM GL_MAP1_INDEX}
  GL_MAP1_NORMAL                      = $0D92;
  {$EXTERNALSYM GL_MAP1_NORMAL}
  GL_MAP1_TEXTURE_COORD_1             = $0D93;
  {$EXTERNALSYM GL_MAP1_TEXTURE_COORD_1}
  GL_MAP1_TEXTURE_COORD_2             = $0D94;
  {$EXTERNALSYM GL_MAP1_TEXTURE_COORD_2}
  GL_MAP1_TEXTURE_COORD_3             = $0D95;
  {$EXTERNALSYM GL_MAP1_TEXTURE_COORD_3}
  GL_MAP1_TEXTURE_COORD_4             = $0D96;
  {$EXTERNALSYM GL_MAP1_TEXTURE_COORD_4}
  GL_MAP1_VERTEX_3                    = $0D97;
  {$EXTERNALSYM GL_MAP1_VERTEX_3}
  GL_MAP1_VERTEX_4                    = $0D98;
  {$EXTERNALSYM GL_MAP1_VERTEX_4}
  GL_MAP2_COLOR_4                     = $0DB0;
  {$EXTERNALSYM GL_MAP2_COLOR_4}
  GL_MAP2_INDEX                       = $0DB1;
  {$EXTERNALSYM GL_MAP2_INDEX}
  GL_MAP2_NORMAL                      = $0DB2;
  {$EXTERNALSYM GL_MAP2_NORMAL}
  GL_MAP2_TEXTURE_COORD_1             = $0DB3;
  {$EXTERNALSYM GL_MAP2_TEXTURE_COORD_1}
  GL_MAP2_TEXTURE_COORD_2             = $0DB4;
  {$EXTERNALSYM GL_MAP2_TEXTURE_COORD_2}
  GL_MAP2_TEXTURE_COORD_3             = $0DB5;
  {$EXTERNALSYM GL_MAP2_TEXTURE_COORD_3}
  GL_MAP2_TEXTURE_COORD_4             = $0DB6;
  {$EXTERNALSYM GL_MAP2_TEXTURE_COORD_4}
  GL_MAP2_VERTEX_3                    = $0DB7;
  {$EXTERNALSYM GL_MAP2_VERTEX_3}
  GL_MAP2_VERTEX_4                    = $0DB8;
  {$EXTERNALSYM GL_MAP2_VERTEX_4}
  GL_MAP1_GRID_DOMAIN                 = $0DD0;
  {$EXTERNALSYM GL_MAP1_GRID_DOMAIN}
  GL_MAP1_GRID_SEGMENTS               = $0DD1;
  {$EXTERNALSYM GL_MAP1_GRID_SEGMENTS}
  GL_MAP2_GRID_DOMAIN                 = $0DD2;
  {$EXTERNALSYM GL_MAP2_GRID_DOMAIN}
  GL_MAP2_GRID_SEGMENTS               = $0DD3;
  {$EXTERNALSYM GL_MAP2_GRID_SEGMENTS}
  GL_TEXTURE_1D                       = $0DE0;
  {$EXTERNALSYM GL_TEXTURE_1D}
  GL_TEXTURE_2D                       = $0DE1;
  {$EXTERNALSYM GL_TEXTURE_2D}

{ GetTextureParameter }
{      GL_TEXTURE_MAG_FILTER }
{      GL_TEXTURE_MIN_FILTER }
{      GL_TEXTURE_WRAP_S }
{      GL_TEXTURE_WRAP_T }
  GL_TEXTURE_WIDTH                    = $1000;
  {$EXTERNALSYM GL_TEXTURE_WIDTH}
  GL_TEXTURE_HEIGHT                   = $1001;
  {$EXTERNALSYM GL_TEXTURE_HEIGHT}
  GL_TEXTURE_COMPONENTS               = $1003;
  {$EXTERNALSYM GL_TEXTURE_COMPONENTS}
  GL_TEXTURE_BORDER_COLOR             = $1004;
  {$EXTERNALSYM GL_TEXTURE_BORDER_COLOR}
  GL_TEXTURE_BORDER                   = $1005;
  {$EXTERNALSYM GL_TEXTURE_BORDER}

{ HintMode }
  GL_DONT_CARE                        = $1100;
  {$EXTERNALSYM GL_DONT_CARE}
  GL_FASTEST                          = $1101;
  {$EXTERNALSYM GL_FASTEST}
  GL_NICEST                           = $1102;
  {$EXTERNALSYM GL_NICEST}

{ HintTarget }
{      GL_PERSPECTIVE_CORRECTION_HINT }
{      GL_POINT_SMOOTH_HINT }
{      GL_LINE_SMOOTH_HINT }
{      GL_POLYGON_SMOOTH_HINT }
{      GL_FOG_HINT }

{ LightModelParameter }
{      GL_LIGHT_MODEL_AMBIENT }
{      GL_LIGHT_MODEL_LOCAL_VIEWER }
{      GL_LIGHT_MODEL_TWO_SIDE }

{ LightParameter }
  GL_AMBIENT                          = $1200;
  {$EXTERNALSYM GL_AMBIENT}
  GL_DIFFUSE                          = $1201;
  {$EXTERNALSYM GL_DIFFUSE}
  GL_SPECULAR                         = $1202;
  {$EXTERNALSYM GL_SPECULAR}
  GL_POSITION                         = $1203;
  {$EXTERNALSYM GL_POSITION}
  GL_SPOT_DIRECTION                   = $1204;
  {$EXTERNALSYM GL_SPOT_DIRECTION}
  GL_SPOT_EXPONENT                    = $1205;
  {$EXTERNALSYM GL_SPOT_EXPONENT}
  GL_SPOT_CUTOFF                      = $1206;
  {$EXTERNALSYM GL_SPOT_CUTOFF}
  GL_CONSTANT_ATTENUATION             = $1207;
  {$EXTERNALSYM GL_CONSTANT_ATTENUATION}
  GL_LINEAR_ATTENUATION               = $1208;
  {$EXTERNALSYM GL_LINEAR_ATTENUATION}
  GL_QUADRATIC_ATTENUATION            = $1209;
  {$EXTERNALSYM GL_QUADRATIC_ATTENUATION}

{ ListMode }
  GL_COMPILE                          = $1300;
  {$EXTERNALSYM GL_COMPILE}
  GL_COMPILE_AND_EXECUTE              = $1301;
  {$EXTERNALSYM GL_COMPILE_AND_EXECUTE}

{ ListNameType }
  GL_BYTE                             = $1400;
  {$EXTERNALSYM GL_BYTE}
  GL_UNSIGNED_BYTE                    = $1401;
  {$EXTERNALSYM GL_UNSIGNED_BYTE}
  GL_SHORT                            = $1402;
  {$EXTERNALSYM GL_SHORT}
  GL_UNSIGNED_SHORT                   = $1403;
  {$EXTERNALSYM GL_UNSIGNED_SHORT}
  GL_INT                              = $1404;
  {$EXTERNALSYM GL_INT}
  GL_UNSIGNED_INT                     = $1405;
  {$EXTERNALSYM GL_UNSIGNED_INT}
  GL_FLOAT                            = $1406;
  {$EXTERNALSYM GL_FLOAT}
  GL_2_BYTES                          = $1407;
  {$EXTERNALSYM GL_2_BYTES}
  GL_3_BYTES                          = $1408;
  {$EXTERNALSYM GL_3_BYTES}
  GL_4_BYTES                          = $1409;
  {$EXTERNALSYM GL_4_BYTES}

{ LogicOp }
  GL_CLEAR                            = $1500;
  {$EXTERNALSYM GL_CLEAR}
  GL_AND                              = $1501;
  {$EXTERNALSYM GL_AND}
  GL_AND_REVERSE                      = $1502;
  {$EXTERNALSYM GL_AND_REVERSE}
  GL_COPY                             = $1503;
  {$EXTERNALSYM GL_COPY}
  GL_AND_INVERTED                     = $1504;
  {$EXTERNALSYM GL_AND_INVERTED}
  GL_NOOP                             = $1505;
  {$EXTERNALSYM GL_NOOP}
  GL_XOR                              = $1506;
  {$EXTERNALSYM GL_XOR}
  GL_OR                               = $1507;
  {$EXTERNALSYM GL_OR}
  GL_NOR                              = $1508;
  {$EXTERNALSYM GL_NOR}
  GL_EQUIV                            = $1509;
  {$EXTERNALSYM GL_EQUIV}
  GL_INVERT                           = $150A;
  {$EXTERNALSYM GL_INVERT}
  GL_OR_REVERSE                       = $150B;
  {$EXTERNALSYM GL_OR_REVERSE}
  GL_COPY_INVERTED                    = $150C;
  {$EXTERNALSYM GL_COPY_INVERTED}
  GL_OR_INVERTED                      = $150D;
  {$EXTERNALSYM GL_OR_INVERTED}
  GL_NAND                             = $150E;
  {$EXTERNALSYM GL_NAND}
  GL_SET                              = $150F;
  {$EXTERNALSYM GL_SET}

{ MapTarget }
{      GL_MAP1_COLOR_4 }
{      GL_MAP1_INDEX }
{      GL_MAP1_NORMAL }
{      GL_MAP1_TEXTURE_COORD_1 }
{      GL_MAP1_TEXTURE_COORD_2 }
{      GL_MAP1_TEXTURE_COORD_3 }
{      GL_MAP1_TEXTURE_COORD_4 }
{      GL_MAP1_VERTEX_3 }
{      GL_MAP1_VERTEX_4 }
{      GL_MAP2_COLOR_4 }
{      GL_MAP2_INDEX }
{      GL_MAP2_NORMAL }
{      GL_MAP2_TEXTURE_COORD_1 }
{      GL_MAP2_TEXTURE_COORD_2 }
{      GL_MAP2_TEXTURE_COORD_3 }
{      GL_MAP2_TEXTURE_COORD_4 }
{      GL_MAP2_VERTEX_3 }
{      GL_MAP2_VERTEX_4 }

{ MaterialFace }
{      GL_FRONT }
{      GL_BACK }
{      GL_FRONT_AND_BACK }

{ MaterialParameter }
  GL_EMISSION                         = $1600;
  {$EXTERNALSYM GL_EMISSION}
  GL_SHININESS                        = $1601;
  {$EXTERNALSYM GL_SHININESS}
  GL_AMBIENT_AND_DIFFUSE              = $1602;
  {$EXTERNALSYM GL_AMBIENT_AND_DIFFUSE}
  GL_COLOR_INDEXES                    = $1603;
  {$EXTERNALSYM GL_COLOR_INDEXES}
{      GL_AMBIENT }
{      GL_DIFFUSE }
{      GL_SPECULAR }

{ MatrixMode }
  GL_MODELVIEW                        = $1700;
  {$EXTERNALSYM GL_MODELVIEW}
  GL_PROJECTION                       = $1701;
  {$EXTERNALSYM GL_PROJECTION}
  GL_TEXTURE                          = $1702;
  {$EXTERNALSYM GL_TEXTURE}

{ MeshMode1 }
{      GL_POINT }
{      GL_LINE }

{ MeshMode2 }
{      GL_POINT }
{      GL_LINE }
{      GL_FILL }

{ PixelCopyType }
  GL_COLOR                            = $1800;
  {$EXTERNALSYM GL_COLOR}
  GL_DEPTH                            = $1801;
  {$EXTERNALSYM GL_DEPTH}
  GL_STENCIL                          = $1802;
  {$EXTERNALSYM GL_STENCIL}

{ PixelFormat }
  GL_COLOR_INDEX                      = $1900;
  {$EXTERNALSYM GL_COLOR_INDEX}
  GL_STENCIL_INDEX                    = $1901;
  {$EXTERNALSYM GL_STENCIL_INDEX}
  GL_DEPTH_COMPONENT                  = $1902;
  {$EXTERNALSYM GL_DEPTH_COMPONENT}
  GL_RED                              = $1903;
  {$EXTERNALSYM GL_RED}
  GL_GREEN                            = $1904;
  {$EXTERNALSYM GL_GREEN}
  GL_BLUE                             = $1905;
  {$EXTERNALSYM GL_BLUE}
  GL_ALPHA                            = $1906;
  {$EXTERNALSYM GL_ALPHA}
  GL_RGB                              = $1907;
  {$EXTERNALSYM GL_RGB}
  GL_RGBA                             = $1908;
  {$EXTERNALSYM GL_RGBA}
  GL_LUMINANCE                        = $1909;
  {$EXTERNALSYM GL_LUMINANCE}
  GL_LUMINANCE_ALPHA                  = $190A;
  {$EXTERNALSYM GL_LUMINANCE_ALPHA}

{ PixelMap }
{      GL_PIXEL_MAP_I_TO_I }
{      GL_PIXEL_MAP_S_TO_S }
{      GL_PIXEL_MAP_I_TO_R }
{      GL_PIXEL_MAP_I_TO_G }
{      GL_PIXEL_MAP_I_TO_B }
{      GL_PIXEL_MAP_I_TO_A }
{      GL_PIXEL_MAP_R_TO_R }
{      GL_PIXEL_MAP_G_TO_G }
{      GL_PIXEL_MAP_B_TO_B }
{      GL_PIXEL_MAP_A_TO_A }

{ PixelStore }
{      GL_UNPACK_SWAP_BYTES }
{      GL_UNPACK_LSB_FIRST }
{      GL_UNPACK_ROW_LENGTH }
{      GL_UNPACK_SKIP_ROWS }
{      GL_UNPACK_SKIP_PIXELS }
{      GL_UNPACK_ALIGNMENT }
{      GL_PACK_SWAP_BYTES }
{      GL_PACK_LSB_FIRST }
{      GL_PACK_ROW_LENGTH }
{      GL_PACK_SKIP_ROWS }
{      GL_PACK_SKIP_PIXELS }
{      GL_PACK_ALIGNMENT }

{ PixelTransfer }
{      GL_MAP_COLOR }
{      GL_MAP_STENCIL }
{      GL_INDEX_SHIFT }
{      GL_INDEX_OFFSET }
{      GL_RED_SCALE }
{      GL_RED_BIAS }
{      GL_GREEN_SCALE }
{      GL_GREEN_BIAS }
{      GL_BLUE_SCALE }
{      GL_BLUE_BIAS }
{      GL_ALPHA_SCALE }
{      GL_ALPHA_BIAS }
{      GL_DEPTH_SCALE }
{      GL_DEPTH_BIAS }

{ PixelType }
  GL_BITMAP                           = $1A00;
  {$EXTERNALSYM GL_BITMAP}
{      GL_BYTE }
{      GL_UNSIGNED_BYTE }
{      GL_SHORT }
{      GL_UNSIGNED_SHORT }
{      GL_INT }
{      GL_UNSIGNED_INT }
{      GL_FLOAT }

{ PolygonMode }
  GL_POINT                            = $1B00;
  {$EXTERNALSYM GL_POINT}
  GL_LINE                             = $1B01;
  {$EXTERNALSYM GL_LINE}
  GL_FILL                             = $1B02;
  {$EXTERNALSYM GL_FILL}

{ ReadBufferMode }
{      GL_FRONT_LEFT }
{      GL_FRONT_RIGHT }
{      GL_BACK_LEFT }
{      GL_BACK_RIGHT }
{      GL_FRONT }
{      GL_BACK }
{      GL_LEFT }
{      GL_RIGHT }
{      GL_AUX0 }
{      GL_AUX1 }
{      GL_AUX2 }
{      GL_AUX3 }

{ RenderingMode }
  GL_RENDER                           = $1C00;
  {$EXTERNALSYM GL_RENDER}
  GL_FEEDBACK                         = $1C01;
  {$EXTERNALSYM GL_FEEDBACK}
  GL_SELECT                           = $1C02;
  {$EXTERNALSYM GL_SELECT}

{ ShadingModel }
  GL_FLAT                             = $1D00;
  {$EXTERNALSYM GL_FLAT}
  GL_SMOOTH                           = $1D01;
  {$EXTERNALSYM GL_SMOOTH}

{ StencilFunction }
{      GL_NEVER }
{      GL_LESS }
{      GL_EQUAL }
{      GL_LEQUAL }
{      GL_GREATER }
{      GL_NOTEQUAL }
{      GL_GEQUAL }
{      GL_ALWAYS }

{ StencilOp }
{      GL_ZERO }
  GL_KEEP                             = $1E00;
  {$EXTERNALSYM GL_KEEP}
  GL_REPLACE                          = $1E01;
  {$EXTERNALSYM GL_REPLACE}
  GL_INCR                             = $1E02;
  {$EXTERNALSYM GL_INCR}
  GL_DECR                             = $1E03;
  {$EXTERNALSYM GL_DECR}
{      GL_INVERT }

{ StringName }
  GL_VENDOR                           = $1F00;
  {$EXTERNALSYM GL_VENDOR}
  GL_RENDERER                         = $1F01;
  {$EXTERNALSYM GL_RENDERER}
  GL_VERSION                          = $1F02;
  {$EXTERNALSYM GL_VERSION}
  GL_EXTENSIONS                       = $1F03;
  {$EXTERNALSYM GL_EXTENSIONS}

{ TextureCoordName }
  GL_S                                = $2000;
  {$EXTERNALSYM GL_S}
  GL_T                                = $2001;
  {$EXTERNALSYM GL_T}
  GL_R                                = $2002;
  {$EXTERNALSYM GL_R}
  GL_Q                                = $2003;
  {$EXTERNALSYM GL_Q}

{ TextureEnvMode }
  GL_MODULATE                         = $2100;
  {$EXTERNALSYM GL_MODULATE}
  GL_DECAL                            = $2101;
  {$EXTERNALSYM GL_DECAL}
{      GL_BLEND }

{ TextureEnvParameter }
  GL_TEXTURE_ENV_MODE                 = $2200;
  {$EXTERNALSYM GL_TEXTURE_ENV_MODE}
  GL_TEXTURE_ENV_COLOR                = $2201;
  {$EXTERNALSYM GL_TEXTURE_ENV_COLOR}

{ TextureEnvTarget }
  GL_TEXTURE_ENV                      = $2300;
  {$EXTERNALSYM GL_TEXTURE_ENV}

{ TextureGenMode }
  GL_EYE_LINEAR                       = $2400;
  {$EXTERNALSYM GL_EYE_LINEAR}
  GL_OBJECT_LINEAR                    = $2401;
  {$EXTERNALSYM GL_OBJECT_LINEAR}
  GL_SPHERE_MAP                       = $2402;
  {$EXTERNALSYM GL_SPHERE_MAP}

{ TextureGenParameter }
  GL_TEXTURE_GEN_MODE                 = $2500;
  {$EXTERNALSYM GL_TEXTURE_GEN_MODE}
  GL_OBJECT_PLANE                     = $2501;
  {$EXTERNALSYM GL_OBJECT_PLANE}
  GL_EYE_PLANE                        = $2502;
  {$EXTERNALSYM GL_EYE_PLANE}

{ TextureMagFilter }
  GL_NEAREST                          = $2600;
  {$EXTERNALSYM GL_NEAREST}
  GL_LINEAR                           = $2601;
  {$EXTERNALSYM GL_LINEAR}

{ TextureMinFilter }
{      GL_NEAREST }
{      GL_LINEAR }
  GL_NEAREST_MIPMAP_NEAREST           = $2700;
  {$EXTERNALSYM GL_NEAREST_MIPMAP_NEAREST}
  GL_LINEAR_MIPMAP_NEAREST            = $2701;
  {$EXTERNALSYM GL_LINEAR_MIPMAP_NEAREST}
  GL_NEAREST_MIPMAP_LINEAR            = $2702;
  {$EXTERNALSYM GL_NEAREST_MIPMAP_LINEAR}
  GL_LINEAR_MIPMAP_LINEAR             = $2703;
  {$EXTERNALSYM GL_LINEAR_MIPMAP_LINEAR}

{ TextureParameterName }
  GL_TEXTURE_MAG_FILTER               = $2800;
  {$EXTERNALSYM GL_TEXTURE_MAG_FILTER}
  GL_TEXTURE_MIN_FILTER               = $2801;
  {$EXTERNALSYM GL_TEXTURE_MIN_FILTER}
  GL_TEXTURE_WRAP_S                   = $2802;
  {$EXTERNALSYM GL_TEXTURE_WRAP_S}
  GL_TEXTURE_WRAP_T                   = $2803;
  {$EXTERNALSYM GL_TEXTURE_WRAP_T}
{      GL_TEXTURE_BORDER_COLOR }

{ TextureTarget }
{      GL_TEXTURE_1D }
{      GL_TEXTURE_2D }

{ TextureWrapMode }
  GL_CLAMP                            = $2900;
  {$EXTERNALSYM GL_CLAMP}
  GL_REPEAT                           = $2901;
  {$EXTERNALSYM GL_REPEAT}

{ ClipPlaneName }
  GL_CLIP_PLANE0                      = $3000;
  {$EXTERNALSYM GL_CLIP_PLANE0}
  GL_CLIP_PLANE1                      = $3001;
  {$EXTERNALSYM GL_CLIP_PLANE1}
  GL_CLIP_PLANE2                      = $3002;
  {$EXTERNALSYM GL_CLIP_PLANE2}
  GL_CLIP_PLANE3                      = $3003;
  {$EXTERNALSYM GL_CLIP_PLANE3}
  GL_CLIP_PLANE4                      = $3004;
  {$EXTERNALSYM GL_CLIP_PLANE4}
  GL_CLIP_PLANE5                      = $3005;
  {$EXTERNALSYM GL_CLIP_PLANE5}

{ LightName }
  GL_LIGHT0                           = $4000;
  {$EXTERNALSYM GL_LIGHT0}
  GL_LIGHT1                           = $4001;
  {$EXTERNALSYM GL_LIGHT1}
  GL_LIGHT2                           = $4002;
  {$EXTERNALSYM GL_LIGHT2}
  GL_LIGHT3                           = $4003;
  {$EXTERNALSYM GL_LIGHT3}
  GL_LIGHT4                           = $4004;
  {$EXTERNALSYM GL_LIGHT4}
  GL_LIGHT5                           = $4005;
  {$EXTERNALSYM GL_LIGHT5}
  GL_LIGHT6                           = $4006;
  {$EXTERNALSYM GL_LIGHT6}
  GL_LIGHT7                           = $4007;
  {$EXTERNALSYM GL_LIGHT7}

// Extensions
  GL_EXT_vertex_array                 = 1;
  {$EXTERNALSYM GL_EXT_vertex_array}
  GL_WIN_swap_hint                    = 1;
  {$EXTERNALSYM GL_WIN_swap_hint}

// EXT_vertex_array
  GL_VERTEX_ARRAY_EXT               = $8074;
  {$EXTERNALSYM GL_VERTEX_ARRAY_EXT}
  GL_NORMAL_ARRAY_EXT               = $8075;
  {$EXTERNALSYM GL_NORMAL_ARRAY_EXT}
  GL_COLOR_ARRAY_EXT                = $8076;
  {$EXTERNALSYM GL_COLOR_ARRAY_EXT}
  GL_INDEX_ARRAY_EXT                = $8077;
  {$EXTERNALSYM GL_INDEX_ARRAY_EXT}
  GL_TEXTURE_COORD_ARRAY_EXT        = $8078;
  {$EXTERNALSYM GL_TEXTURE_COORD_ARRAY_EXT}
  GL_EDGE_FLAG_ARRAY_EXT            = $8079;
  {$EXTERNALSYM GL_EDGE_FLAG_ARRAY_EXT}
  GL_VERTEX_ARRAY_SIZE_EXT          = $807A;
  {$EXTERNALSYM GL_VERTEX_ARRAY_SIZE_EXT}
  GL_VERTEX_ARRAY_TYPE_EXT          = $807B;
  {$EXTERNALSYM GL_VERTEX_ARRAY_TYPE_EXT}
  GL_VERTEX_ARRAY_STRIDE_EXT        = $807C;
  {$EXTERNALSYM GL_VERTEX_ARRAY_STRIDE_EXT}
  GL_VERTEX_ARRAY_COUNT_EXT         = $807D;
  {$EXTERNALSYM GL_VERTEX_ARRAY_COUNT_EXT}
  GL_NORMAL_ARRAY_TYPE_EXT          = $807E;
  {$EXTERNALSYM GL_NORMAL_ARRAY_TYPE_EXT}
  GL_NORMAL_ARRAY_STRIDE_EXT        = $807F;
  {$EXTERNALSYM GL_NORMAL_ARRAY_STRIDE_EXT}
  GL_NORMAL_ARRAY_COUNT_EXT         = $8080;
  {$EXTERNALSYM GL_NORMAL_ARRAY_COUNT_EXT}
  GL_COLOR_ARRAY_SIZE_EXT           = $8081;
  {$EXTERNALSYM GL_COLOR_ARRAY_SIZE_EXT}
  GL_COLOR_ARRAY_TYPE_EXT           = $8082;
  {$EXTERNALSYM GL_COLOR_ARRAY_TYPE_EXT}
  GL_COLOR_ARRAY_STRIDE_EXT         = $8083;
  {$EXTERNALSYM GL_COLOR_ARRAY_STRIDE_EXT}
  GL_COLOR_ARRAY_COUNT_EXT          = $8084;
  {$EXTERNALSYM GL_COLOR_ARRAY_COUNT_EXT}
  GL_INDEX_ARRAY_TYPE_EXT           = $8085;
  {$EXTERNALSYM GL_INDEX_ARRAY_TYPE_EXT}
  GL_INDEX_ARRAY_STRIDE_EXT         = $8086;
  {$EXTERNALSYM GL_INDEX_ARRAY_STRIDE_EXT}
  GL_INDEX_ARRAY_COUNT_EXT          = $8087;
  {$EXTERNALSYM GL_INDEX_ARRAY_COUNT_EXT}
  GL_TEXTURE_COORD_ARRAY_SIZE_EXT   = $8088;
  {$EXTERNALSYM GL_TEXTURE_COORD_ARRAY_SIZE_EXT}
  GL_TEXTURE_COORD_ARRAY_TYPE_EXT   = $8089;
  {$EXTERNALSYM GL_TEXTURE_COORD_ARRAY_TYPE_EXT}
  GL_TEXTURE_COORD_ARRAY_STRIDE_EXT = $808A;
  {$EXTERNALSYM GL_TEXTURE_COORD_ARRAY_STRIDE_EXT}
  GL_TEXTURE_COORD_ARRAY_COUNT_EXT  = $808B;
  {$EXTERNALSYM GL_TEXTURE_COORD_ARRAY_COUNT_EXT}
  GL_EDGE_FLAG_ARRAY_STRIDE_EXT     = $808C;
  {$EXTERNALSYM GL_EDGE_FLAG_ARRAY_STRIDE_EXT}
  GL_EDGE_FLAG_ARRAY_COUNT_EXT      = $808D;
  {$EXTERNALSYM GL_EDGE_FLAG_ARRAY_COUNT_EXT}
  GL_VERTEX_ARRAY_POINTER_EXT       = $808E;
  {$EXTERNALSYM GL_VERTEX_ARRAY_POINTER_EXT}
  GL_NORMAL_ARRAY_POINTER_EXT       = $808F;
  {$EXTERNALSYM GL_NORMAL_ARRAY_POINTER_EXT}
  GL_COLOR_ARRAY_POINTER_EXT        = $8090;
  {$EXTERNALSYM GL_COLOR_ARRAY_POINTER_EXT}
  GL_INDEX_ARRAY_POINTER_EXT        = $8091;
  {$EXTERNALSYM GL_INDEX_ARRAY_POINTER_EXT}
  GL_TEXTURE_COORD_ARRAY_POINTER_EXT = $8092;
  {$EXTERNALSYM GL_TEXTURE_COORD_ARRAY_POINTER_EXT}
  GL_EDGE_FLAG_ARRAY_POINTER_EXT    = $8093;
  {$EXTERNALSYM GL_EDGE_FLAG_ARRAY_POINTER_EXT}

type
  PPointFloat = ^TPointFloat;
  {$EXTERNALSYM _POINTFLOAT}
  _POINTFLOAT = record
    X,Y: Single;
  end;
  TPointFloat = _POINTFLOAT;
  {$EXTERNALSYM POINTFLOAT}
  POINTFLOAT = _POINTFLOAT;

  PGlyphMetricsFloat = ^TGlyphMetricsFloat;
  {$EXTERNALSYM _GLYPHMETRICSFLOAT}
  _GLYPHMETRICSFLOAT = record
    gmfBlackBoxX: Single;
    gmfBlackBoxY: Single;
    gmfptGlyphOrigin: TPointFloat;
    gmfCellIncX: Single;
    gmfCellIncY: Single;
  end;
  TGlyphMetricsFloat = _GLYPHMETRICSFLOAT;
  {$EXTERNALSYM GLYPHMETRICSFLOAT}
  GLYPHMETRICSFLOAT = _GLYPHMETRICSFLOAT;

const
  {$EXTERNALSYM WGL_FONT_LINES}
  WGL_FONT_LINES      = 0;
  {$EXTERNALSYM WGL_FONT_POLYGONS}
  WGL_FONT_POLYGONS   = 1;

{***********************************************************}

procedure glAccum (op: GLenum; value: GLfloat); stdcall;
  {$EXTERNALSYM glAccum}
procedure glAlphaFunc (func: GLenum; ref: GLclampf); stdcall;
  {$EXTERNALSYM glAlphaFunc}
procedure glBegin (mode: GLenum); stdcall;
  {$EXTERNALSYM glBegin}
procedure glBitmap (width, height: GLsizei; xorig, yorig: GLfloat;
                    xmove, ymove: GLfloat; bitmap: Pointer); stdcall;
  {$EXTERNALSYM glBitmap}
procedure glBlendFunc (sfactor, dfactor: GLenum); stdcall;
  {$EXTERNALSYM glBlendFunc}
procedure glCallList (list: GLuint); stdcall;
  {$EXTERNALSYM glCallList}
procedure glCallLists (n: GLsizei; cltype: GLenum; lists: Pointer); stdcall;
  {$EXTERNALSYM glCallLists}
procedure glClear (mask: GLbitfield); stdcall;
  {$EXTERNALSYM glClear}
procedure glClearAccum (red, green, blue, alpha: GLfloat); stdcall;
  {$EXTERNALSYM glClearAccum}
procedure glClearColor (red, green, blue, alpha: GLclampf); stdcall;
  {$EXTERNALSYM glClearColor}
procedure glClearDepth (depth: GLclampd); stdcall;
  {$EXTERNALSYM glClearDepth}
procedure glClearIndex (c: GLfloat); stdcall;
  {$EXTERNALSYM glClearIndex}
procedure glClearStencil (s: GLint); stdcall;
  {$EXTERNALSYM glClearStencil}
procedure glClipPlane (plane: GLenum; equation: PGLDouble); stdcall;
  {$EXTERNALSYM glClipPlane}

procedure glColor3b (red, green, blue: GLbyte); stdcall;
  {$EXTERNALSYM glColor3b}
procedure glColor3bv (v: PGLByte); stdcall;
  {$EXTERNALSYM glColor3bv}
procedure glColor3d (red, green, blue: GLdouble); stdcall;
  {$EXTERNALSYM glColor3d}
procedure glColor3dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glColor3dv}
procedure glColor3f (red, green, blue: GLfloat); stdcall;
  {$EXTERNALSYM glColor3f}
procedure glColor3fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glColor3fv}
procedure glColor3i (red, green, blue: GLint); stdcall;
  {$EXTERNALSYM glColor3i}
procedure glColor3iv (v: PGLint); stdcall;
  {$EXTERNALSYM glColor3iv}
procedure glColor3s (red, green, blue: GLshort); stdcall;
  {$EXTERNALSYM glColor3s}
procedure glColor3sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glColor3sv}
procedure glColor3ub (red, green, blue: GLubyte); stdcall;
  {$EXTERNALSYM glColor3ub}
procedure glColor3ubv (v: PGLubyte); stdcall;
  {$EXTERNALSYM glColor3ubv}
procedure glColor3ui (red, green, blue: GLuint); stdcall;
  {$EXTERNALSYM glColor3ui}
procedure glColor3uiv (v: PGLuint); stdcall;
  {$EXTERNALSYM glColor3uiv}
procedure glColor3us (red, green, blue: GLushort); stdcall;
  {$EXTERNALSYM glColor3us}
procedure glColor3usv (v: PGLushort); stdcall;
  {$EXTERNALSYM glColor3usv}
procedure glColor4b (red, green, blue, alpha: GLbyte); stdcall;
  {$EXTERNALSYM glColor4b}
procedure glColor4bv (v: PGLbyte); stdcall;
  {$EXTERNALSYM glColor4bv}
procedure glColor4d (red, green, blue, alpha: GLdouble); stdcall;
  {$EXTERNALSYM glColor4d}
procedure glColor4dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glColor4dv}
procedure glColor4f (red, green, blue, alpha: GLfloat); stdcall;
  {$EXTERNALSYM glColor4f}
procedure glColor4fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glColor4fv}
procedure glColor4i (red, green, blue, alpha: GLint); stdcall;
  {$EXTERNALSYM glColor4i}
procedure glColor4iv (v: PGLint); stdcall;
  {$EXTERNALSYM glColor4iv}
procedure glColor4s (red, green, blue, alpha: GLshort); stdcall;
  {$EXTERNALSYM glColor4s}
procedure glColor4sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glColor4sv}
procedure glColor4ub (red, green, blue, alpha: GLubyte); stdcall;
  {$EXTERNALSYM glColor4ub}
procedure glColor4ubv (v: PGLubyte); stdcall;
  {$EXTERNALSYM glColor4ubv}
procedure glColor4ui (red, green, blue, alpha: GLuint); stdcall;
  {$EXTERNALSYM glColor4ui}
procedure glColor4uiv (v: PGLuint); stdcall;
  {$EXTERNALSYM glColor4uiv}
procedure glColor4us (red, green, blue, alpha: GLushort); stdcall;
  {$EXTERNALSYM glColor4us}
procedure glColor4usv (v: PGLushort); stdcall;
  {$EXTERNALSYM glColor4usv}
procedure glColor(red, green, blue: GLbyte); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue: GLdouble); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue: GLfloat); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue: GLint); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue: GLshort); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue: GLubyte); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue: GLuint); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue: GLushort); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue, alpha: GLbyte); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue, alpha: GLdouble); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue, alpha: GLfloat); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue, alpha: GLint); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue, alpha: GLshort); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue, alpha: GLubyte); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue, alpha: GLuint); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor(red, green, blue, alpha: GLushort); stdcall; overload;
  {$EXTERNALSYM glColor}
procedure glColor3(v: PGLbyte); stdcall; overload;
  {$EXTERNALSYM glColor3}
procedure glColor3(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glColor3}
procedure glColor3(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glColor3}
procedure glColor3(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glColor3}
procedure glColor3(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glColor3}
procedure glColor3(v: PGLubyte); stdcall; overload;
  {$EXTERNALSYM glColor3}
procedure glColor3(v: PGLuint); stdcall; overload;
  {$EXTERNALSYM glColor3}
procedure glColor3(v: PGLushort); stdcall; overload;
  {$EXTERNALSYM glColor3}
procedure glColor4(v: PGLbyte); stdcall; overload;
  {$EXTERNALSYM glColor4}
procedure glColor4(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glColor4}
procedure glColor4(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glColor4}
procedure glColor4(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glColor4}
procedure glColor4(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glColor4}
procedure glColor4(v: PGLubyte); stdcall; overload;
  {$EXTERNALSYM glColor4}
procedure glColor4(v: PGLuint); stdcall; overload;
  {$EXTERNALSYM glColor4}
procedure glColor4(v: PGLushort); stdcall; overload;
  {$EXTERNALSYM glColor4}

procedure glColorMask (red, green, blue, alpha: GLboolean); stdcall;
  {$EXTERNALSYM glColorMask}
procedure glColorMaterial (face, mode: GLenum); stdcall;
  {$EXTERNALSYM glColorMaterial}
procedure glCopyPixels (x,y: GLint; width, height: GLsizei; pixeltype: GLenum); stdcall;
  {$EXTERNALSYM glCopyPixels}
procedure glCullFace (mode: GLenum); stdcall;
  {$EXTERNALSYM glCullFace}
procedure glDeleteLists (list: GLuint; range: GLsizei); stdcall;
  {$EXTERNALSYM glDeleteLists}
procedure glDepthFunc (func: GLenum); stdcall;
  {$EXTERNALSYM glDepthFunc}
procedure glDepthMask (flag: GLboolean); stdcall;
  {$EXTERNALSYM glDepthMask}
procedure glDepthRange (zNear, zFar: GLclampd); stdcall;
  {$EXTERNALSYM glDepthRange}
procedure glDisable (cap: GLenum); stdcall;
  {$EXTERNALSYM glDisable}
procedure glDrawBuffer (mode: GLenum); stdcall;
  {$EXTERNALSYM glDrawBuffer}
procedure glDrawPixels (width, height: GLsizei; format, pixeltype: GLenum;
             pixels: Pointer); stdcall;
  {$EXTERNALSYM glDrawPixels}
procedure glEdgeFlag (flag: GLboolean); stdcall;
  {$EXTERNALSYM glEdgeFlag}
procedure glEdgeFlagv (flag: PGLboolean); stdcall;
  {$EXTERNALSYM glEdgeFlagv}
procedure glEnable (cap: GLenum); stdcall;
  {$EXTERNALSYM glEnable}
procedure glEnd; stdcall;
  {$EXTERNALSYM glEnd}
procedure glEndList; stdcall;
  {$EXTERNALSYM glEndList}

procedure glEvalCoord1d (u: GLdouble); stdcall;
  {$EXTERNALSYM glEvalCoord1d}
procedure glEvalCoord1dv (u: PGLdouble); stdcall;
  {$EXTERNALSYM glEvalCoord1dv}
procedure glEvalCoord1f (u: GLfloat); stdcall;
  {$EXTERNALSYM glEvalCoord1f}
procedure glEvalCoord1fv (u: PGLfloat); stdcall;
  {$EXTERNALSYM glEvalCoord1fv}
procedure glEvalCoord2d (u,v: GLdouble); stdcall;
  {$EXTERNALSYM glEvalCoord2d}
procedure glEvalCoord2dv (u: PGLdouble); stdcall;
  {$EXTERNALSYM glEvalCoord2dv}
procedure glEvalCoord2f (u,v: GLfloat); stdcall;
  {$EXTERNALSYM glEvalCoord2f}
procedure glEvalCoord2fv (u: PGLfloat); stdcall;
  {$EXTERNALSYM glEvalCoord2fv}
procedure glEvalCoord(u: GLdouble); stdcall; overload;
  {$EXTERNALSYM glEvalCoord}
procedure glEvalCoord(u: GLfloat); stdcall; overload;
  {$EXTERNALSYM glEvalCoord}
procedure glEvalCoord(u,v: GLdouble); stdcall; overload;
  {$EXTERNALSYM glEvalCoord}
procedure glEvalCoord(u,v: GLfloat); stdcall; overload;
  {$EXTERNALSYM glEvalCoord}
procedure glEvalCoord1(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glEvalCoord1}
procedure glEvalCoord1(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glEvalCoord1}
procedure glEvalCoord2(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glEvalCoord2}
procedure glEvalCoord2(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glEvalCoord2}

procedure glEvalMesh1 (mode: GLenum; i1, i2: GLint); stdcall;
  {$EXTERNALSYM glEvalMesh1}
procedure glEvalMesh2 (mode: GLenum; i1, i2, j1, j2: GLint); stdcall;
  {$EXTERNALSYM glEvalMesh2}
procedure glEvalMesh(mode: GLenum; i1, i2: GLint); stdcall; overload;
  {$EXTERNALSYM glEvalMesh}
procedure glEvalMesh(mode: GLenum; i1, i2, j1, j2: GLint); stdcall; overload;
  {$EXTERNALSYM glEvalMesh}

procedure glEvalPoint1 (i: GLint); stdcall;
  {$EXTERNALSYM glEvalPoint1}
procedure glEvalPoint2 (i,j: GLint); stdcall;
  {$EXTERNALSYM glEvalPoint2}
procedure glEvalPoint(i: GLint); stdcall; overload;
  {$EXTERNALSYM glEvalPoint}
procedure glEvalPoint(i,j: GLint); stdcall; overload;
  {$EXTERNALSYM glEvalPoint}

procedure glFeedbackBuffer (size: GLsizei; buftype: GLenum; buffer: PGLFloat); stdcall;
  {$EXTERNALSYM glFeedbackBuffer}
procedure glFinish; stdcall;
  {$EXTERNALSYM glFinish}
procedure glFlush; stdcall;
  {$EXTERNALSYM glFlush}

procedure glFogf (pname: GLenum; param: GLfloat); stdcall;
  {$EXTERNALSYM glFogf}
procedure glFogfv (pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glFogfv}
procedure glFogi (pname: GLenum; param: GLint); stdcall;
  {$EXTERNALSYM glFogi}
procedure glFogiv (pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glFogiv}
procedure glFog(pname: GLenum; param: GLfloat); stdcall; overload;
  {$EXTERNALSYM glFog}
procedure glFog(pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glFog}
procedure glFog(pname: GLenum; param: GLint); stdcall; overload;
  {$EXTERNALSYM glFog}
procedure glFog(pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glFog}

procedure glFrontFace (mode: GLenum); stdcall;
  {$EXTERNALSYM glFrontFace}
procedure glFrustum (left, right, bottom, top, zNear, zFar: GLdouble); stdcall;
  {$EXTERNALSYM glFrustum}
function  glGenLists (range: GLsizei): GLuint; stdcall;
  {$EXTERNALSYM glGenLists}
procedure glGetBooleanv (pname: GLenum; params: PGLboolean); stdcall;
  {$EXTERNALSYM glGetBooleanv}
procedure glGetClipPlane (plane: GLenum; equation: PGLdouble); stdcall;
  {$EXTERNALSYM glGetClipPlane}
procedure glGetDoublev (pname: GLenum; params: PGLdouble); stdcall;
  {$EXTERNALSYM glGetDoublev}
function  glGetError: GLenum; stdcall;
  {$EXTERNALSYM glGetError}
procedure glGetFloatv (pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glGetFloatv}
procedure glGetIntegerv (pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glGetIntegerv}

procedure glGetLightfv (light: GLenum; pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glGetLightfv}
procedure glGetLightiv (light: GLenum; pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glGetLightiv}
procedure glGetLight(light: GLenum; pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glGetLight}
procedure glGetLight(light: GLenum; pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glGetLight}

procedure glGetMapdv (target: GLenum; query: GLenum; v: PGLdouble); stdcall;
  {$EXTERNALSYM glGetMapdv}
procedure glGetMapfv (target: GLenum; query: GLenum; v: PGLfloat); stdcall;
  {$EXTERNALSYM glGetMapfv}
procedure glGetMapiv (target: GLenum; query: GLenum; v: PGLint); stdcall;
  {$EXTERNALSYM glGetMapiv}
procedure glGetMap(target: GLenum; query: GLenum; v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glGetMap}
procedure glGetMap(target: GLenum; query: GLenum; v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glGetMap}
procedure glGetMap(target: GLenum; query: GLenum; v: PGLint); stdcall; overload;
  {$EXTERNALSYM glGetMap}

procedure glGetMaterialfv (face: GLenum; pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glGetMaterialfv}
procedure glGetMaterialiv (face: GLenum; pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glGetMaterialiv}
procedure glGetMaterial(face: GLenum; pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glGetMaterial}
procedure glGetMaterial(face: GLenum; pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glGetMaterial}

procedure glGetPixelMapfv (map: GLenum; values: PGLfloat); stdcall;
  {$EXTERNALSYM glGetPixelMapfv}
procedure glGetPixelMapuiv (map: GLenum; values: PGLuint); stdcall;
  {$EXTERNALSYM glGetPixelMapuiv}
procedure glGetPixelMapusv (map: GLenum; values: PGLushort); stdcall;
  {$EXTERNALSYM glGetPixelMapusv}
procedure glGetPixelMap(map: GLenum; values: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glGetPixelMap}
procedure glGetPixelMap(map: GLenum; values: PGLuint); stdcall; overload;
  {$EXTERNALSYM glGetPixelMap}
procedure glGetPixelMap(map: GLenum; values: PGLushort); stdcall; overload;
  {$EXTERNALSYM glGetPixelMap}

procedure glGetPolygonStipple (var mask: GLubyte); stdcall;
  {$EXTERNALSYM glGetPolygonStipple}
function  glGetString (name: GLenum): PChar; stdcall;
  {$EXTERNALSYM glGetString}

procedure glGetTexEnvfv (target: GLenum; pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glGetTexEnvfv}
procedure glGetTexEnviv (target: GLenum; pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glGetTexEnviv}
procedure glGetTexEnv(target: GLenum; pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glGetTexEnv}
procedure glGetTexEnv(target: GLenum; pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glGetTexEnv}

procedure glGetTexGendv (coord: GLenum; pname: GLenum; params: PGLdouble); stdcall;
  {$EXTERNALSYM glGetTexGendv}
procedure glGetTexGenfv (coord: GLenum; pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glGetTexGenfv}
procedure glGetTexGeniv (coord: GLenum; pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glGetTexGeniv}
procedure glGetTexGen(coord: GLenum; pname: GLenum; params: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glGetTexGen}
procedure glGetTexGen(coord: GLenum; pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glGetTexGen}
procedure glGetTexGen(coord: GLenum; pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glGetTexGen}

procedure glGetTexImage (target: GLenum; level: GLint; format: GLenum; _type: GLenum; pixels: pointer); stdcall;
  {$EXTERNALSYM glGetTexImage}

procedure glGetTexLevelParameterfv (target: GLenum; level: GLint; pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glGetTexLevelParameterfv}
procedure glGetTexLevelParameteriv (target: GLenum; level: GLint; pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glGetTexLevelParameteriv}
procedure glGetTexLevelParameter(target: GLenum; level: GLint; pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glGetTexLevelParameter}
procedure glGetTexLevelParameter(target: GLenum; level: GLint; pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glGetTexLevelParameter}

procedure glGetTexParameterfv (target, pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glGetTexParameterfv}
procedure glGetTexParameteriv (target, pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glGetTexParameteriv}
procedure glGetTexParameter(target, pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glGetTexParameter}
procedure glGetTexParameter(target, pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glGetTexParameter}

procedure glHint (target, mode: GLenum); stdcall;
  {$EXTERNALSYM glHint}
procedure glIndexMask (mask: GLuint); stdcall;
  {$EXTERNALSYM glIndexMask}

procedure glIndexd (c: GLdouble); stdcall;
  {$EXTERNALSYM glIndexd}
procedure glIndexdv (c: PGLdouble); stdcall;
  {$EXTERNALSYM glIndexdv}
procedure glIndexf (c: GLfloat); stdcall;
  {$EXTERNALSYM glIndexf}
procedure glIndexfv (c: PGLfloat); stdcall;
  {$EXTERNALSYM glIndexfv}
procedure glIndexi (c: GLint); stdcall;
  {$EXTERNALSYM glIndexi}
procedure glIndexiv (c: PGLint); stdcall;
  {$EXTERNALSYM glIndexiv}
procedure glIndexs (c: GLshort); stdcall;
  {$EXTERNALSYM glIndexs}
procedure glIndexsv (c: PGLshort); stdcall;
  {$EXTERNALSYM glIndexsv}
procedure glIndex(c: GLdouble); stdcall; overload;
  {$EXTERNALSYM glIndex}
procedure glIndex(c: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glIndex}
procedure glIndex(c: GLfloat); stdcall;  overload;
  {$EXTERNALSYM glIndex}
procedure glIndex(c: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glIndex}
procedure glIndex(c: GLint); stdcall; overload;
  {$EXTERNALSYM glIndex}
procedure glIndex(c: PGLint); stdcall; overload;
  {$EXTERNALSYM glIndex}
procedure glIndex(c: GLshort); stdcall; overload;
  {$EXTERNALSYM glIndex}
procedure glIndex(c: PGLshort); stdcall; overload;
  {$EXTERNALSYM glIndex}

procedure glInitNames; stdcall;
  {$EXTERNALSYM glInitNames}
function  glIsEnabled (cap: GLenum): GLBoolean; stdcall;
  {$EXTERNALSYM glIsEnabled}
function  glIsList (list: GLuint): GLBoolean;   stdcall;
  {$EXTERNALSYM glIsList}

procedure glLightModelf (pname: GLenum; param: GLfloat); stdcall;
  {$EXTERNALSYM glLightModelf}
procedure glLightModelfv (pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glLightModelfv}
procedure glLightModeli (pname: GLenum; param: GLint); stdcall;
  {$EXTERNALSYM glLightModeli}
procedure glLightModeliv (pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glLightModeliv}
procedure glLightModel(pname: GLenum; param: GLfloat); stdcall; overload;
  {$EXTERNALSYM glLightModel}
procedure glLightModel(pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glLightModel}
procedure glLightModel(pname: GLenum; param: GLint); stdcall; overload;
  {$EXTERNALSYM glLightModel}
procedure glLightModel(pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glLightModel}

procedure glLightf (light, pname: GLenum; param: GLfloat); stdcall;
  {$EXTERNALSYM glLightf}
procedure glLightfv (light, pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glLightfv}
procedure glLighti (light, pname: GLenum; param: GLint); stdcall;
  {$EXTERNALSYM glLighti}
procedure glLightiv (light, pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glLightiv}
procedure glLight(light, pname: GLenum; param: GLfloat); stdcall; overload;
  {$EXTERNALSYM glLight}
procedure glLight(light, pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glLight}
procedure glLight(light, pname: GLenum; param: GLint); stdcall; overload;
  {$EXTERNALSYM glLight}
procedure glLight(light, pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glLight}

procedure glLineStipple (factor: GLint; pattern: GLushort); stdcall;
  {$EXTERNALSYM glLineStipple}
procedure glLineWidth (width: GLfloat); stdcall;
  {$EXTERNALSYM glLineWidth}
procedure glListBase (base: GLuint); stdcall;
  {$EXTERNALSYM glListBase}
procedure glLoadIdentity; stdcall;
  {$EXTERNALSYM glLoadIdentity}

procedure glLoadMatrixd (m: PGLdouble); stdcall;
  {$EXTERNALSYM glLoadMatrixd}
procedure glLoadMatrixf (m: PGLfloat); stdcall;
  {$EXTERNALSYM glLoadMatrixf}
procedure glLoadMatrix(m: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glLoadMatrix}
procedure glLoadMatrix(m: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glLoadMatrix}

procedure glLoadName (name: GLuint); stdcall;
  {$EXTERNALSYM glLoadName}
procedure glLogicOp (opcode: GLenum); stdcall;
  {$EXTERNALSYM glLogicOp}

procedure glMap1d (target: GLenum; u1,u2: GLdouble; stride, order: GLint;
  Points: PGLdouble); stdcall;
  {$EXTERNALSYM glMap1d}
procedure glMap1f (target: GLenum; u1,u2: GLfloat; stride, order: GLint;
  Points: PGLfloat); stdcall;
  {$EXTERNALSYM glMap1f}
procedure glMap2d (target: GLenum;
  u1,u2: GLdouble; ustride, uorder: GLint;
  v1,v2: GLdouble; vstride, vorder: GLint; Points: PGLdouble); stdcall;
  {$EXTERNALSYM glMap2d}
procedure glMap2f (target: GLenum;
  u1,u2: GLfloat; ustride, uorder: GLint;
  v1,v2: GLfloat; vstride, vorder: GLint; Points: PGLfloat); stdcall;
  {$EXTERNALSYM glMap2f}
procedure glMap(target: GLenum; u1,u2: GLdouble; stride, order: GLint;
  Points: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glMap}
procedure glMap(target: GLenum; u1,u2: GLfloat; stride, order: GLint;
  Points: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glMap}
procedure glMap(target: GLenum;
  u1,u2: GLdouble; ustride, uorder: GLint;
  v1,v2: GLdouble; vstride, vorder: GLint; Points: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glMap}
procedure glMap(target: GLenum;
  u1,u2: GLfloat; ustride, uorder: GLint;
  v1,v2: GLfloat; vstride, vorder: GLint; Points: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glMap}

procedure glMapGrid1d (un: GLint; u1, u2: GLdouble); stdcall;
  {$EXTERNALSYM glMapGrid1d}
procedure glMapGrid1f (un: GLint; u1, u2: GLfloat); stdcall;
  {$EXTERNALSYM glMapGrid1f}
procedure glMapGrid2d (un: GLint; u1, u2: GLdouble;
                       vn: GLint; v1, v2: GLdouble); stdcall;
  {$EXTERNALSYM glMapGrid2d}
procedure glMapGrid2f (un: GLint; u1, u2: GLfloat;
                       vn: GLint; v1, v2: GLfloat); stdcall;
  {$EXTERNALSYM glMapGrid2f}
procedure glMapGrid(un: GLint; u1, u2: GLdouble); stdcall; overload;
  {$EXTERNALSYM glMapGrid}
procedure glMapGrid(un: GLint; u1, u2: GLfloat); stdcall;  overload;
  {$EXTERNALSYM glMapGrid}
procedure glMapGrid(un: GLint; u1, u2: GLdouble;
                    vn: GLint; v1, v2: GLdouble); stdcall; overload;
  {$EXTERNALSYM glMapGrid}
procedure glMapGrid(un: GLint; u1, u2: GLfloat;
                    vn: GLint; v1, v2: GLfloat); stdcall; overload;
  {$EXTERNALSYM glMapGrid}

procedure glMaterialf (face, pname: GLenum; param: GLfloat); stdcall;
  {$EXTERNALSYM glMaterialf}
procedure glMaterialfv (face, pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glMaterialfv}
procedure glMateriali (face, pname: GLenum; param: GLint); stdcall;
  {$EXTERNALSYM glMateriali}
procedure glMaterialiv (face, pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glMaterialiv}
procedure glMaterial(face, pname: GLenum; param: GLfloat); stdcall; overload;
  {$EXTERNALSYM glMaterial}
procedure glMaterial(face, pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glMaterial}
procedure glMaterial(face, pname: GLenum; param: GLint); stdcall; overload;
  {$EXTERNALSYM glMaterial}
procedure glMaterial(face, pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glMaterial}

procedure glMatrixMode (mode: GLenum); stdcall;
  {$EXTERNALSYM glMatrixMode}

procedure glMultMatrixd (m: PGLdouble); stdcall;
  {$EXTERNALSYM glMultMatrixd}
procedure glMultMatrixf (m: PGLfloat); stdcall;
  {$EXTERNALSYM glMultMatrixf}
procedure glMultMatrix(m: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glMultMatrix}
procedure glMultMatrix(m: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glMultMatrix}

procedure glNewList (ListIndex: GLuint; mode: GLenum); stdcall;
  {$EXTERNALSYM glNewList}

procedure glNormal3b (nx, ny, nz: GLbyte); stdcall;
  {$EXTERNALSYM glNormal3b}
procedure glNormal3bv (v: PGLbyte); stdcall;
  {$EXTERNALSYM glNormal3bv}
procedure glNormal3d (nx, ny, nz: GLdouble); stdcall;
  {$EXTERNALSYM glNormal3d}
procedure glNormal3dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glNormal3dv}
procedure glNormal3f (nx, ny, nz: GLFloat); stdcall;
  {$EXTERNALSYM glNormal3f}
procedure glNormal3fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glNormal3fv}
procedure glNormal3i (nx, ny, nz: GLint); stdcall;
  {$EXTERNALSYM glNormal3i}
procedure glNormal3iv (v: PGLint); stdcall;
  {$EXTERNALSYM glNormal3iv}
procedure glNormal3s (nx, ny, nz: GLshort); stdcall;
  {$EXTERNALSYM glNormal3s}
procedure glNormal3sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glNormal3sv}
procedure glNormal(nx, ny, nz: GLbyte); stdcall; overload;
  {$EXTERNALSYM glNormal}
procedure glNormal3(v: PGLbyte); stdcall; overload;
  {$EXTERNALSYM glNormal3}
procedure glNormal(nx, ny, nz: GLdouble); stdcall; overload;
  {$EXTERNALSYM glNormal}
procedure glNormal3(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glNormal3}
procedure glNormal(nx, ny, nz: GLFloat); stdcall; overload;
  {$EXTERNALSYM glNormal}
procedure glNormal3(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glNormal3}
procedure glNormal(nx, ny, nz: GLint); stdcall; overload;
  {$EXTERNALSYM glNormal}
procedure glNormal3(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glNormal3}
procedure glNormal(nx, ny, nz: GLshort); stdcall; overload;
  {$EXTERNALSYM glNormal}
procedure glNormal3(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glNormal3}

procedure glOrtho (left, right, bottom, top, zNear, zFar: GLdouble); stdcall;
  {$EXTERNALSYM glOrtho}
procedure glPassThrough (token: GLfloat); stdcall;
  {$EXTERNALSYM glPassThrough}

procedure glPixelMapfv (map: GLenum; mapsize: GLint; values: PGLfloat); stdcall;
  {$EXTERNALSYM glPixelMapfv}
procedure glPixelMapuiv (map: GLenum; mapsize: GLint; values: PGLuint); stdcall;
  {$EXTERNALSYM glPixelMapuiv}
procedure glPixelMapusv (map: GLenum; mapsize: GLint; values: PGLushort); stdcall;
  {$EXTERNALSYM glPixelMapusv}
procedure glPixelMap(map: GLenum; mapsize: GLint; values: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glPixelMap}
procedure glPixelMap(map: GLenum; mapsize: GLint; values: PGLuint); stdcall;  overload;
  {$EXTERNALSYM glPixelMap}
procedure glPixelMap(map: GLenum; mapsize: GLint; values: PGLushort); stdcall; overload;
  {$EXTERNALSYM glPixelMap}

procedure glPixelStoref (pname: GLenum; param: GLfloat); stdcall;
  {$EXTERNALSYM glPixelStoref}
procedure glPixelStorei (pname: GLenum; param: GLint); stdcall;
  {$EXTERNALSYM glPixelStorei}
procedure glPixelStore(pname: GLenum; param: GLfloat); stdcall; overload;
  {$EXTERNALSYM glPixelStore}
procedure glPixelStore(pname: GLenum; param: GLint); stdcall; overload;
  {$EXTERNALSYM glPixelStore}

procedure glPixelTransferf (pname: GLenum; param: GLfloat); stdcall;
  {$EXTERNALSYM glPixelTransferf}
procedure glPixelTransferi (pname: GLenum; param: GLint); stdcall;
  {$EXTERNALSYM glPixelTransferi}
procedure glPixelTransfer(pname: GLenum; param: GLfloat); stdcall; overload;
  {$EXTERNALSYM glPixelTransfer}
procedure glPixelTransfer(pname: GLenum; param: GLint); stdcall; overload;
  {$EXTERNALSYM glPixelTransfer}

procedure glPixelZoom (xfactor, yfactor: GLfloat); stdcall;
  {$EXTERNALSYM glPixelZoom}
procedure glPointSize (size: GLfloat); stdcall;
  {$EXTERNALSYM glPointSize}
procedure glPolygonMode (face, mode: GLenum); stdcall;
  {$EXTERNALSYM glPolygonMode}
procedure glPolygonStipple (mask: PGLubyte); stdcall;
  {$EXTERNALSYM glPolygonStipple}
procedure glPopAttrib; stdcall;
  {$EXTERNALSYM glPopAttrib}
procedure glPopMatrix; stdcall;
  {$EXTERNALSYM glPopMatrix}
procedure glPopName; stdcall;
  {$EXTERNALSYM glPopName}
procedure glPushAttrib(mask: GLbitfield); stdcall;
  {$EXTERNALSYM glPushAttrib}
procedure glPushMatrix; stdcall;
  {$EXTERNALSYM glPushMatrix}
procedure glPushName(name: GLuint); stdcall;
  {$EXTERNALSYM glPushName}

procedure glRasterPos2d (x,y: GLdouble); stdcall;
  {$EXTERNALSYM glRasterPos2d}
procedure glRasterPos2dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glRasterPos2dv}
procedure glRasterPos2f (x,y: GLfloat); stdcall;
  {$EXTERNALSYM glRasterPos2f}
procedure glRasterPos2fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glRasterPos2fv}
procedure glRasterPos2i (x,y: GLint); stdcall;
  {$EXTERNALSYM glRasterPos2i}
procedure glRasterPos2iv (v: PGLint); stdcall;
  {$EXTERNALSYM glRasterPos2iv}
procedure glRasterPos2s (x,y: GLshort); stdcall;
  {$EXTERNALSYM glRasterPos2s}
procedure glRasterPos2sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glRasterPos2sv}
procedure glRasterPos3d (x,y,z: GLdouble); stdcall;
  {$EXTERNALSYM glRasterPos3d}
procedure glRasterPos3dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glRasterPos3dv}
procedure glRasterPos3f (x,y,z: GLfloat); stdcall;
  {$EXTERNALSYM glRasterPos3f}
procedure glRasterPos3fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glRasterPos3fv}
procedure glRasterPos3i (x,y,z: GLint); stdcall;
  {$EXTERNALSYM glRasterPos3i}
procedure glRasterPos3iv (v: PGLint); stdcall;
  {$EXTERNALSYM glRasterPos3iv}
procedure glRasterPos3s (x,y,z: GLshort); stdcall;
  {$EXTERNALSYM glRasterPos3s}
procedure glRasterPos3sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glRasterPos3sv}
procedure glRasterPos4d (x,y,z,w: GLdouble); stdcall;
  {$EXTERNALSYM glRasterPos4d}
procedure glRasterPos4dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glRasterPos4dv}
procedure glRasterPos4f (x,y,z,w: GLfloat); stdcall;
  {$EXTERNALSYM glRasterPos4f}
procedure glRasterPos4fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glRasterPos4fv}
procedure glRasterPos4i (x,y,z,w: GLint); stdcall;
  {$EXTERNALSYM glRasterPos4i}
procedure glRasterPos4iv (v: PGLint); stdcall;
  {$EXTERNALSYM glRasterPos4iv}
procedure glRasterPos4s (x,y,z,w: GLshort); stdcall;
  {$EXTERNALSYM glRasterPos4s}
procedure glRasterPos4sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glRasterPos4sv}
procedure glRasterPos(x,y: GLdouble); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos2(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glRasterPos2}
procedure glRasterPos(x,y: GLfloat); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos2(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glRasterPos2}
procedure glRasterPos(x,y: GLint); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos2(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glRasterPos2}
procedure glRasterPos(x,y: GLshort); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos2(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glRasterPos2}
procedure glRasterPos(x,y,z: GLdouble); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos3(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glRasterPos3}
procedure glRasterPos(x,y,z: GLfloat); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos3(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glRasterPos3}
procedure glRasterPos(x,y,z: GLint); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos3(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glRasterPos3}
procedure glRasterPos(x,y,z: GLshort); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos3(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glRasterPos3}
procedure glRasterPos(x,y,z,w: GLdouble); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos4(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glRasterPos4}
procedure glRasterPos(x,y,z,w: GLfloat); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos4(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glRasterPos4}
procedure glRasterPos(x,y,z,w: GLint); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos4(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glRasterPos4}
procedure glRasterPos(x,y,z,w: GLshort); stdcall; overload;
  {$EXTERNALSYM glRasterPos}
procedure glRasterPos4(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glRasterPos4}

procedure glReadBuffer (mode: GLenum); stdcall;
  {$EXTERNALSYM glReadBuffer}
procedure glReadPixels (x,y: GLint; width, height: GLsizei;
  format, _type: GLenum; pixels: Pointer); stdcall;
  {$EXTERNALSYM glReadPixels}

procedure glRectd (x1, y1, x2, y2: GLdouble); stdcall;
  {$EXTERNALSYM glRectd}
procedure glRectdv (v1, v2: PGLdouble); stdcall;
  {$EXTERNALSYM glRectdv}
procedure glRectf (x1, y1, x2, y2: GLfloat); stdcall;
  {$EXTERNALSYM glRectf}
procedure glRectfv (v1, v2: PGLfloat); stdcall;
  {$EXTERNALSYM glRectfv}
procedure glRecti (x1, y1, x2, y2: GLint); stdcall;
  {$EXTERNALSYM glRecti}
procedure glRectiv (v1, v2: PGLint); stdcall;
  {$EXTERNALSYM glRectiv}
procedure glRects (x1, y1, x2, y2: GLshort); stdcall;
  {$EXTERNALSYM glRects}
procedure glRectsv (v1, v2: PGLshort); stdcall;
  {$EXTERNALSYM glRectsv}
procedure glRect(x1, y1, x2, y2: GLdouble); stdcall; overload;
  {$EXTERNALSYM glRect}
procedure glRect(v1, v2: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glRect}
procedure glRect(x1, y1, x2, y2: GLfloat); stdcall; overload;
  {$EXTERNALSYM glRect}
procedure glRect(v1, v2: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glRect}
procedure glRect(x1, y1, x2, y2: GLint); stdcall; overload;
  {$EXTERNALSYM glRect}
procedure glRect(v1, v2: PGLint); stdcall; overload;
  {$EXTERNALSYM glRect}
procedure glRect(x1, y1, x2, y2: GLshort); stdcall; overload;
  {$EXTERNALSYM glRect}
procedure glRect(v1, v2: PGLshort); stdcall; overload;
  {$EXTERNALSYM glRect}

function  glRenderMode (mode: GLenum): GLint; stdcall;
  {$EXTERNALSYM glRenderMode}

procedure glRotated (angle, x,y,z: GLdouble); stdcall;
  {$EXTERNALSYM glRotated}
procedure glRotatef (angle, x,y,z: GLfloat); stdcall;
  {$EXTERNALSYM glRotatef}
procedure glRotate(angle, x,y,z: GLdouble); stdcall; overload;
  {$EXTERNALSYM glRotate}
procedure glRotate(angle, x,y,z: GLfloat); stdcall; overload;
  {$EXTERNALSYM glRotate}

procedure glScaled (x,y,z: GLdouble); stdcall;
  {$EXTERNALSYM glScaled}
procedure glScalef (x,y,z: GLfloat); stdcall;
  {$EXTERNALSYM glScalef}
procedure glScale(x,y,z: GLdouble); stdcall; overload;
  {$EXTERNALSYM glScale}
procedure glScale(x,y,z: GLfloat); stdcall; overload;
  {$EXTERNALSYM glScale}

procedure glScissor (x,y: GLint; width, height: GLsizei); stdcall;
  {$EXTERNALSYM glScissor}
procedure glSelectBuffer (size: GLsizei; buffer: PGLuint); stdcall;
  {$EXTERNALSYM glSelectBuffer}
procedure glShadeModel (mode: GLenum); stdcall;
  {$EXTERNALSYM glShadeModel}
procedure glStencilFunc (func: GLenum; ref: GLint; mask: GLuint); stdcall;
  {$EXTERNALSYM glStencilFunc}
procedure glStencilMask (mask: GLuint); stdcall;
  {$EXTERNALSYM glStencilMask}
procedure glStencilOp (fail, zfail, zpass: GLenum); stdcall;
  {$EXTERNALSYM glStencilOp}

procedure glTexCoord1d (s: GLdouble); stdcall;
  {$EXTERNALSYM glTexCoord1d}
procedure glTexCoord1dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glTexCoord1dv}
procedure glTexCoord1f (s: GLfloat); stdcall;
  {$EXTERNALSYM glTexCoord1f}
procedure glTexCoord1fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glTexCoord1fv}
procedure glTexCoord1i (s: GLint); stdcall;
  {$EXTERNALSYM glTexCoord1i}
procedure glTexCoord1iv (v: PGLint); stdcall;
  {$EXTERNALSYM glTexCoord1iv}
procedure glTexCoord1s (s: GLshort); stdcall;
  {$EXTERNALSYM glTexCoord1s}
procedure glTexCoord1sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glTexCoord1sv}
procedure glTexCoord2d (s,t: GLdouble); stdcall;
  {$EXTERNALSYM glTexCoord2d}
procedure glTexCoord2dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glTexCoord2dv}
procedure glTexCoord2f (s,t: GLfloat); stdcall;
  {$EXTERNALSYM glTexCoord2f}
procedure glTexCoord2fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glTexCoord2fv}
procedure glTexCoord2i (s,t: GLint); stdcall;
  {$EXTERNALSYM glTexCoord2i}
procedure glTexCoord2iv (v: PGLint); stdcall;
  {$EXTERNALSYM glTexCoord2iv}
procedure glTexCoord2s (s,t: GLshort); stdcall;
  {$EXTERNALSYM glTexCoord2s}
procedure glTexCoord2sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glTexCoord2sv}
procedure glTexCoord3d (s,t,r: GLdouble); stdcall;
  {$EXTERNALSYM glTexCoord3d}
procedure glTexCoord3dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glTexCoord3dv}
procedure glTexCoord3f (s,t,r: GLfloat); stdcall;
  {$EXTERNALSYM glTexCoord3f}
procedure glTexCoord3fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glTexCoord3fv}
procedure glTexCoord3i (s,t,r: GLint); stdcall;
  {$EXTERNALSYM glTexCoord3i}
procedure glTexCoord3iv (v: PGLint); stdcall;
  {$EXTERNALSYM glTexCoord3iv}
procedure glTexCoord3s (s,t,r: GLshort); stdcall;
  {$EXTERNALSYM glTexCoord3s}
procedure glTexCoord3sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glTexCoord3sv}
procedure glTexCoord4d (s,t,r,q: GLdouble); stdcall;
  {$EXTERNALSYM glTexCoord4d}
procedure glTexCoord4dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glTexCoord4dv}
procedure glTexCoord4f (s,t,r,q: GLfloat); stdcall;
  {$EXTERNALSYM glTexCoord4f}
procedure glTexCoord4fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glTexCoord4fv}
procedure glTexCoord4i (s,t,r,q: GLint); stdcall;
  {$EXTERNALSYM glTexCoord4i}
procedure glTexCoord4iv (v: PGLint); stdcall;
  {$EXTERNALSYM glTexCoord4iv}
procedure glTexCoord4s (s,t,r,q: GLshort); stdcall;
  {$EXTERNALSYM glTexCoord4s}
procedure glTexCoord4sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glTexCoord4sv}
procedure glTexCoord(s: GLdouble); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord1(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glTexCoord1}
procedure glTexCoord(s: GLfloat); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord1(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glTexCoord1}
procedure glTexCoord(s: GLint); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord1(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glTexCoord1}
procedure glTexCoord(s: GLshort); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord1(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glTexCoord1}
procedure glTexCoord(s,t: GLdouble); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord2(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glTexCoord2}
procedure glTexCoord(s,t: GLfloat); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord2(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glTexCoord2}
procedure glTexCoord(s,t: GLint); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord2(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glTexCoord2}
procedure glTexCoord(s,t: GLshort); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord2(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glTexCoord2}
procedure glTexCoord(s,t,r: GLdouble); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord3(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glTexCoord3}
procedure glTexCoord(s,t,r: GLfloat); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord3(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glTexCoord3}
procedure glTexCoord(s,t,r: GLint); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord3(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glTexCoord3}
procedure glTexCoord(s,t,r: GLshort); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord3(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glTexCoord3}
procedure glTexCoord(s,t,r,q: GLdouble); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord4(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glTexCoord4}
procedure glTexCoord(s,t,r,q: GLfloat); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord4(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glTexCoord4}
procedure glTexCoord(s,t,r,q: GLint); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord4(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glTexCoord4}
procedure glTexCoord(s,t,r,q: GLshort); stdcall; overload;
  {$EXTERNALSYM glTexCoord}
procedure glTexCoord4(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glTexCoord4}

procedure glTexEnvf (target, pname: GLenum; param: GLfloat); stdcall;
  {$EXTERNALSYM glTexEnvf}
procedure glTexEnvfv (target, pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glTexEnvfv}
procedure glTexEnvi (target, pname: GLenum; param: GLint); stdcall;
  {$EXTERNALSYM glTexEnvi}
procedure glTexEnviv (target, pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glTexEnviv}
procedure glTexEnv(target, pname: GLenum; param: GLfloat); stdcall; overload;
  {$EXTERNALSYM glTexEnv}
procedure glTexEnv(target, pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glTexEnv}
procedure glTexEnv(target, pname: GLenum; param: GLint); stdcall; overload;
  {$EXTERNALSYM glTexEnv}
procedure glTexEnv(target, pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glTexEnv}

procedure glTexGend (coord, pname: GLenum; param: GLdouble); stdcall;
  {$EXTERNALSYM glTexGend}
procedure glTexGendv (coord, pname: GLenum; params: PGLdouble); stdcall;
  {$EXTERNALSYM glTexGendv}
procedure glTexGenf (coord, pname: GLenum; param: GLfloat); stdcall;
  {$EXTERNALSYM glTexGenf}
procedure glTexGenfv (coord, pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glTexGenfv}
procedure glTexGeni (coord, pname: GLenum; param: GLint); stdcall;
  {$EXTERNALSYM glTexGeni}
procedure glTexGeniv (coord, pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glTexGeniv}
procedure glTexGen(coord, pname: GLenum; param: GLdouble); stdcall; overload;
  {$EXTERNALSYM glTexGen}
procedure glTexGen(coord, pname: GLenum; params: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glTexGen}
procedure glTexGen(coord, pname: GLenum; param: GLfloat); stdcall; overload;
  {$EXTERNALSYM glTexGen}
procedure glTexGen(coord, pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glTexGen}
procedure glTexGen(coord, pname: GLenum; param: GLint); stdcall; overload;
  {$EXTERNALSYM glTexGen}
procedure glTexGen(coord, pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glTexGen}

procedure glTexImage1D (target: GLenum; level, components: GLint;
  width: GLsizei; border: GLint; format, _type: GLenum; pixels: Pointer); stdcall;
  {$EXTERNALSYM glTexImage1D}
procedure glTexImage2D (target: GLenum; level, components: GLint;
  width, height: GLsizei; border: GLint; format, _type: GLenum; pixels: Pointer); stdcall;
  {$EXTERNALSYM glTexImage2D}

procedure glTexParameterf (target, pname: GLenum; param: GLfloat); stdcall;
  {$EXTERNALSYM glTexParameterf}
procedure glTexParameterfv (target, pname: GLenum; params: PGLfloat); stdcall;
  {$EXTERNALSYM glTexParameterfv}
procedure glTexParameteri (target, pname: GLenum; param: GLint); stdcall;
  {$EXTERNALSYM glTexParameteri}
procedure glTexParameteriv (target, pname: GLenum; params: PGLint); stdcall;
  {$EXTERNALSYM glTexParameteriv}
procedure glTexParameter(target, pname: GLenum; param: GLfloat); stdcall; overload;
  {$EXTERNALSYM glTexParameter}
procedure glTexParameter(target, pname: GLenum; params: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glTexParameter}
procedure glTexParameter(target, pname: GLenum; param: GLint); stdcall; overload;
  {$EXTERNALSYM glTexParameter}
procedure glTexParameter(target, pname: GLenum; params: PGLint); stdcall; overload;
  {$EXTERNALSYM glTexParameter}

procedure glTranslated (x,y,z: GLdouble); stdcall;
  {$EXTERNALSYM glTranslated}
procedure glTranslatef (x,y,z: GLfloat); stdcall;
  {$EXTERNALSYM glTranslatef}
procedure glTranslate(x,y,z: GLdouble); stdcall; overload;
  {$EXTERNALSYM glTranslate}
procedure glTranslate(x,y,z: GLfloat); stdcall; overload;
  {$EXTERNALSYM glTranslate}

procedure glVertex2d (x,y: GLdouble); stdcall;
  {$EXTERNALSYM glVertex2d}
procedure glVertex2dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glVertex2dv}
procedure glVertex2f (x,y: GLfloat); stdcall;
  {$EXTERNALSYM glVertex2f}
procedure glVertex2fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glVertex2fv}
procedure glVertex2i (x,y: GLint); stdcall;
  {$EXTERNALSYM glVertex2i}
procedure glVertex2iv (v: PGLint); stdcall;
  {$EXTERNALSYM glVertex2iv}
procedure glVertex2s (x,y: GLshort); stdcall;
  {$EXTERNALSYM glVertex2s}
procedure glVertex2sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glVertex2sv}
procedure glVertex3d (x,y,z: GLdouble); stdcall;
  {$EXTERNALSYM glVertex3d}
procedure glVertex3dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glVertex3dv}
procedure glVertex3f (x,y,z: GLfloat); stdcall;
  {$EXTERNALSYM glVertex3f}
procedure glVertex3fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glVertex3fv}
procedure glVertex3i (x,y,z: GLint); stdcall;
  {$EXTERNALSYM glVertex3i}
procedure glVertex3iv (v: PGLint); stdcall;
  {$EXTERNALSYM glVertex3iv}
procedure glVertex3s (x,y,z: GLshort); stdcall;
  {$EXTERNALSYM glVertex3s}
procedure glVertex3sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glVertex3sv}
procedure glVertex4d (x,y,z,w: GLdouble); stdcall;
  {$EXTERNALSYM glVertex4d}
procedure glVertex4dv (v: PGLdouble); stdcall;
  {$EXTERNALSYM glVertex4dv}
procedure glVertex4f (x,y,z,w: GLfloat); stdcall;
  {$EXTERNALSYM glVertex4f}
procedure glVertex4fv (v: PGLfloat); stdcall;
  {$EXTERNALSYM glVertex4fv}
procedure glVertex4i (x,y,z,w: GLint); stdcall;
  {$EXTERNALSYM glVertex4i}
procedure glVertex4iv (v: PGLint); stdcall;
  {$EXTERNALSYM glVertex4iv}
procedure glVertex4s (x,y,z,w: GLshort); stdcall;
  {$EXTERNALSYM glVertex4s}
procedure glVertex4sv (v: PGLshort); stdcall;
  {$EXTERNALSYM glVertex4sv}
procedure glVertex(x,y: GLdouble); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex2(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glVertex2}
procedure glVertex(x,y: GLfloat); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex2(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glVertex2}
procedure glVertex(x,y: GLint); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex2(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glVertex2}
procedure glVertex(x,y: GLshort); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex2(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glVertex2}
procedure glVertex(x,y,z: GLdouble); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex3(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glVertex3}
procedure glVertex(x,y,z: GLfloat); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex3(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glVertex3}
procedure glVertex(x,y,z: GLint); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex3(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glVertex3}
procedure glVertex(x,y,z: GLshort); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex3(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glVertex3}
procedure glVertex(x,y,z,w: GLdouble); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex4(v: PGLdouble); stdcall; overload;
  {$EXTERNALSYM glVertex4}
procedure glVertex(x,y,z,w: GLfloat); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex4(v: PGLfloat); stdcall; overload;
  {$EXTERNALSYM glVertex4}
procedure glVertex(x,y,z,w: GLint); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex4(v: PGLint); stdcall; overload;
  {$EXTERNALSYM glVertex4}
procedure glVertex(x,y,z,w: GLshort); stdcall; overload;
  {$EXTERNALSYM glVertex}
procedure glVertex4(v: PGLshort); stdcall; overload;
  {$EXTERNALSYM glVertex4}

procedure glViewport (x,y: GLint; width, height: GLsizei); stdcall;
  {$EXTERNALSYM glViewport}

type

// EXT_vertex_array
  PFNGLARRAYELEMENTEXTPROC = procedure (i: GLint) stdcall;
  {$EXTERNALSYM PFNGLARRAYELEMENTEXTPROC}
  TGLARRAYELEMENTEXTPROC = PFNGLARRAYELEMENTEXTPROC;
  PFNGLDRAWARRAYSEXTPROC = procedure (mode: GLenum; first: GLint; count: GLsizei) stdcall;
  {$EXTERNALSYM PFNGLDRAWARRAYSEXTPROC}
  TGLDRAWARRAYSEXTPROC = PFNGLDRAWARRAYSEXTPROC;
  PFNGLVERTEXPOINTEREXTPROC = procedure (size: GLint; type_: GLenum;
    stride, count: GLsizei; P: Pointer) stdcall;
  {$EXTERNALSYM PFNGLVERTEXPOINTEREXTPROC}
  TGLVERTEXPOINTEREXTPROC = PFNGLVERTEXPOINTEREXTPROC;
  PFNGLNORMALPOINTEREXTPROC = procedure (type_: GLenum; stride, count: GLsizei;
    P: Pointer) stdcall;
  {$EXTERNALSYM PFNGLNORMALPOINTEREXTPROC}
  TGLNORMALPOINTEREXTPROC = PFNGLNORMALPOINTEREXTPROC;
  PFNGLCOLORPOINTEREXTPROC = procedure (size: GLint; type_: GLenum;
    stride, count: GLsizei; P: Pointer) stdcall;
  {$EXTERNALSYM PFNGLCOLORPOINTEREXTPROC}
  TGLCOLORPOINTEREXTPROC = PFNGLCOLORPOINTEREXTPROC;
  PFNGLINDEXPOINTEREXTPROC = procedure (type_: GLenum; stride, count: GLsizei;
    P: Pointer) stdcall;
  {$EXTERNALSYM PFNGLINDEXPOINTEREXTPROC}
  TGLINDEXPOINTEREXTPROC = PFNGLINDEXPOINTEREXTPROC;
  PFNGLTEXCOORDPOINTEREXTPROC = procedure (size: GLint; type_: GLenum;
    stride, count: GLsizei; P: Pointer) stdcall;
  {$EXTERNALSYM PFNGLTEXCOORDPOINTEREXTPROC}
  TGLTEXCOORDPOINTEREXTPROC = PFNGLTEXCOORDPOINTEREXTPROC;
  PFNGLEDGEFLAGPOINTEREXTPROC = procedure (stride, count: GLsizei;
    P: PGLboolean) stdcall;
  {$EXTERNALSYM PFNGLEDGEFLAGPOINTEREXTPROC}
  TGLEDGEFLAGPOINTEREXTPROC = PFNGLEDGEFLAGPOINTEREXTPROC;
  PFNGLGETPOINTERVEXTPROC = procedure (pname: GLenum; var Params) stdcall;
  {$EXTERNALSYM PFNGLGETPOINTERVEXTPROC}
  TGLGETPOINTERVEXTPROC = PFNGLGETPOINTERVEXTPROC;

// WIN_swap_hint

  PFNGLADDSWAPHINTRECTWINPROC = procedure (x, y: GLint; width, height: GLsizei) stdcall;
  {$EXTERNALSYM PFNGLADDSWAPHINTRECTWINPROC}
  TGLADDSWAPHINTRECTWINPROC = PFNGLADDSWAPHINTRECTWINPROC;

{ OpenGL Utility routines (glu.h) =======================================}

function gluErrorString (errCode: GLenum): PChar; stdcall;
  {$EXTERNALSYM gluErrorString}
function gluErrorUnicodeStringEXT (errCode: GLenum): PWChar; stdcall;
  {$EXTERNALSYM gluErrorUnicodeStringEXT}
function gluGetString (name: GLenum): PChar; stdcall;
  {$EXTERNALSYM gluGetString}

procedure gluLookAt(eyex, eyey, eyez,
                    centerx, centery, centerz,
                    upx, upy, upz: GLdouble); stdcall;
  {$EXTERNALSYM gluLookAt}
procedure gluOrtho2D(left, right, bottom, top: GLdouble); stdcall;
  {$EXTERNALSYM gluOrtho2D}
procedure gluPerspective(fovy, aspect, zNear, zFar: GLdouble); stdcall;
  {$EXTERNALSYM gluPerspective}
procedure gluPickMatrix (x, y, width, height: GLdouble; viewport: PGLint); stdcall;
  {$EXTERNALSYM gluPickMatrix}
function  gluProject (objx, objy, obyz: GLdouble;
                      modelMatrix: PGLdouble;
                      projMatrix: PGLdouble;
                      viewport: PGLint;
                      var winx, winy, winz: GLDouble): Integer; stdcall;
  {$EXTERNALSYM gluProject}
function  gluUnProject(winx, winy, winz: GLdouble;
                      modelMatrix: PGLdouble;
                      projMatrix: PGLdouble;
                      viewport: PGLint;
                      var objx, objy, objz: GLdouble): Integer; stdcall;
  {$EXTERNALSYM gluUnProject}
function  gluScaleImage(format: GLenum;
   widthin, heightin: GLint; typein: GLenum; datain: Pointer;
   widthout, heightout: GLint; typeout: GLenum; dataout: Pointer): Integer; stdcall;
  {$EXTERNALSYM gluScaleImage}

function  gluBuild1DMipmaps (target: GLenum; components, width: GLint;
                             format, atype: GLenum; data: Pointer): Integer; stdcall;
  {$EXTERNALSYM gluBuild1DMipmaps}
function  gluBuild2DMipmaps (target: GLenum; components, width, height: GLint;
                             format, atype: GLenum; data: Pointer): Integer; stdcall;
  {$EXTERNALSYM gluBuild2DMipmaps}

type
  _GLUquadricObj = record end;
  GLUquadricObj = ^_GLUquadricObj;
  {$EXTERNALSYM GLUquadricObj}

  GLUquadricErrorProc = procedure (error: GLenum) stdcall;
  TGLUquadricErrorProc = GLUquadricErrorProc;
  {$EXTERNALSYM GLUquadricErrorProc}

function  gluNewQuadric: GLUquadricObj; stdcall;
  {$EXTERNALSYM gluNewQuadric}
procedure gluDeleteQuadric (state: GLUquadricObj); stdcall;
  {$EXTERNALSYM gluDeleteQuadric}
procedure gluQuadricNormals (quadObject: GLUquadricObj; normals: GLenum);  stdcall;
  {$EXTERNALSYM gluQuadricNormals}
procedure gluQuadricTexture (quadObject: GLUquadricObj; textureCoords: GLboolean );stdcall;
  {$EXTERNALSYM gluQuadricTexture}
procedure gluQuadricOrientation (quadObject: GLUquadricObj; orientation: GLenum); stdcall;
  {$EXTERNALSYM gluQuadricOrientation}
procedure gluQuadricDrawStyle (quadObject: GLUquadricObj; drawStyle: GLenum); stdcall;
  {$EXTERNALSYM gluQuadricDrawStyle}
procedure gluCylinder (quadObject: GLUquadricObj;
  baseRadius, topRadius, height: GLdouble; slices, stacks: GLint); stdcall;
  {$EXTERNALSYM gluCylinder}
procedure gluDisk (quadObject: GLUquadricObj;
  innerRadius, outerRadius: GLdouble; slices, loops: GLint); stdcall;
  {$EXTERNALSYM gluDisk}
procedure gluPartialDisk (quadObject: GLUquadricObj;
  innerRadius, outerRadius: GLdouble; slices, loops: GLint;
  startAngle, sweepAngle: GLdouble); stdcall;
  {$EXTERNALSYM gluPartialDisk}
procedure gluSphere (quadObject: GLUquadricObj; radius: GLdouble; slices, loops: GLint); stdcall;
procedure gluQuadricCallback (quadObject: GLUquadricObj; which: GLenum;
  callback: Pointer); stdcall;
  {$EXTERNALSYM gluSphere}

type
  _GLUtesselator = record end;
  GLUtesselator = ^_GLUtesselator;
  {$EXTERNALSYM GLUtesselator}

  // tesselator callback procedure types
  GLUtessBeginProc = procedure (a: GLenum) stdcall;
  {$EXTERNALSYM GLUtessBeginProc}
  TGLUtessBeginProc = GLUtessBeginProc;
  GLUtessEdgeFlagProc = procedure (flag: GLboolean) stdcall;
  {$EXTERNALSYM GLUtessEdgeFlagProc}
  TGLUtessEdgeFlagProc = GLUtessEdgeFlagProc;
  GLUtessVertexProc = procedure (p: Pointer) stdcall;
  {$EXTERNALSYM GLUtessVertexProc}
  TGLUtessVertexProc = GLUtessVertexProc;
  GLUtessEndProc = procedure stdcall;
  {$EXTERNALSYM GLUtessEndProc}
  TGLUtessEndProc = GLUtessEndProc;
  GLUtessErrorProc = TGLUquadricErrorProc;
  {$EXTERNALSYM GLUtessErrorProc}
  GLUtessCombineProc = procedure (a: PGLdouble; b: Pointer;
                                   c: PGLfloat; var d: Pointer) stdcall;
  {$EXTERNALSYM GLUtessCombineProc}
  TGLUtessCombineProc = GLUtessCombineProc;

function gluNewTess: GLUtesselator; stdcall;
  {$EXTERNALSYM gluNewTess}
procedure gluDeleteTess( tess: GLUtesselator ); stdcall;
  {$EXTERNALSYM gluDeleteTess}
procedure gluTessBeginPolygon( tess: GLUtesselator; gon_data: Pointer ); stdcall;
  {$EXTERNALSYM gluTessBeginPolygon}
procedure gluTessBeginContour( tess: GLUtesselator ); stdcall;
  {$EXTERNALSYM gluTessBeginContour}
procedure gluTessVertex( tess: GLUtesselator; coords: PGLdouble; data: Pointer ); stdcall;
  {$EXTERNALSYM gluTessVertex}
procedure gluTessEndContour( tess: GLUtesselator ); stdcall;
  {$EXTERNALSYM gluTessEndContour}
procedure gluTessEndPolygon( tess: GLUtesselator ); stdcall;
  {$EXTERNALSYM gluTessEndPolygon}
procedure gluTessProperty( tess: GLUtesselator; which: GLenum; value: GLdouble); stdcall;
  {$EXTERNALSYM gluTessProperty}
procedure gluTessNormal( tess: GLUtesselator; x,y,z: GLdouble); stdcall;
  {$EXTERNALSYM gluTessNormal}
procedure gluTessCallback( tess: GLUtesselator; which: GLenum; callback: pointer); stdcall;
  {$EXTERNALSYM gluTessCallback}

type
  TGLUnurbsObj = record end;
  GLUnurbsObj = ^TGLUnurbsObj;
  {$EXTERNALSYM GLUnurbsObj}

  GLUnurbsErrorProc = GLUquadricErrorProc;
  {$EXTERNALSYM GLUnurbsErrorProc}
  TGLUnurbsErrorProc = GLUnurbsErrorProc;

function gluNewNurbsRenderer: GLUnurbsObj; stdcall;
  {$EXTERNALSYM gluNewNurbsRenderer}
procedure gluDeleteNurbsRenderer (nobj: GLUnurbsObj); stdcall;
  {$EXTERNALSYM gluDeleteNurbsRenderer}
procedure gluBeginSurface (nobj: GLUnurbsObj); stdcall;
  {$EXTERNALSYM gluBeginSurface}
procedure gluBeginCurve (nobj: GLUnurbsObj); stdcall;
  {$EXTERNALSYM gluBeginCurve}
procedure gluEndCurve (nobj: GLUnurbsObj); stdcall;
  {$EXTERNALSYM gluEndCurve}
procedure gluEndSurface (nobj: GLUnurbsObj); stdcall;
  {$EXTERNALSYM gluEndSurface}
procedure gluBeginTrim (nobj: GLUnurbsObj); stdcall;
  {$EXTERNALSYM gluBeginTrim}
procedure gluEndTrim (nobj: GLUnurbsObj); stdcall;
  {$EXTERNALSYM gluEndTrim}
procedure gluPwlCurve (nobj: GLUnurbsObj; count: GLint; points: PGLfloat;
  stride: GLint; _type: GLenum); stdcall;
  {$EXTERNALSYM gluPwlCurve}
procedure gluNurbsCurve (nobj: GLUnurbsObj; nknots: GLint; knot: PGLfloat;
  stride: GLint; ctlpts: PGLfloat; order: GLint; _type: GLenum); stdcall;
  {$EXTERNALSYM gluNurbsCurve}
procedure gluNurbsSurface (nobj: GLUnurbsObj;
  sknot_count: GLint; sknot: PGLfloat;
  tknot_count: GLint; tknot: PGLfloat;
  s_stride, t_stride: GLint;
  ctlpts: PGLfloat; sorder, torder: GLint; _type: GLenum); stdcall;
  {$EXTERNALSYM gluNurbsSurface}
procedure gluLoadSamplingMatrices (nobj: GLUnurbsObj;
  modelMatrix: PGLdouble; projMatrix: PGLdouble; viewport: PGLint); stdcall;
  {$EXTERNALSYM gluLoadSamplingMatrices}
procedure gluNurbsProperty (nobj: GLUnurbsObj; prop: GLenum; value: GLfloat); stdcall;
  {$EXTERNALSYM gluNurbsProperty}
procedure gluGetNurbsProperty (nobj: GLUnurbsObj; prop: GLenum; var value: GLfloat); stdcall;
  {$EXTERNALSYM gluGetNurbsProperty}
procedure gluNurbsCallback (nobj: GLUnurbsObj; which: GLenum; callback: pointer); stdcall;
  {$EXTERNALSYM gluNurbsCallback}

{****           Generic constants               ****}
const
  GLU_VERSION_1_1  =               1;
  {$EXTERNALSYM GLU_VERSION_1_1}

{ Errors: (return value 0 = no error) }
  GLU_INVALID_ENUM       = 100900;
  {$EXTERNALSYM GLU_INVALID_ENUM}
  GLU_INVALID_VALUE      = 100901;
  {$EXTERNALSYM GLU_INVALID_VALUE}
  GLU_OUT_OF_MEMORY      = 100902;
  {$EXTERNALSYM GLU_OUT_OF_MEMORY}
  GLU_INCOMPATIBLE_GL_VERSION  =   100903;
  {$EXTERNALSYM GLU_INCOMPATIBLE_GL_VERSION}

{ gets }
  GLU_VERSION            = 100800;
  {$EXTERNALSYM GLU_VERSION}
  GLU_EXTENSIONS         = 100801;
  {$EXTERNALSYM GLU_EXTENSIONS}

{ For laughs: }
  GLU_TRUE               = GL_TRUE;
  {$EXTERNALSYM GLU_TRUE}
  GLU_FALSE              = GL_FALSE;
  {$EXTERNALSYM GLU_FALSE}

{***           Quadric constants               ***}

{ Types of normals: }
  GLU_SMOOTH             = 100000;
  {$EXTERNALSYM GLU_SMOOTH}
  GLU_FLAT               = 100001;
  {$EXTERNALSYM GLU_FLAT}
  GLU_NONE               = 100002;
  {$EXTERNALSYM GLU_NONE}

{ DrawStyle types: }
  GLU_POINT              = 100010;
  {$EXTERNALSYM GLU_POINT}
  GLU_LINE               = 100011;
  {$EXTERNALSYM GLU_LINE}
  GLU_FILL               = 100012;
  {$EXTERNALSYM GLU_FILL}
  GLU_SILHOUETTE         = 100013;
  {$EXTERNALSYM GLU_SILHOUETTE}

{ Orientation types: }
  GLU_OUTSIDE            = 100020;
  {$EXTERNALSYM GLU_OUTSIDE}
  GLU_INSIDE             = 100021;
  {$EXTERNALSYM GLU_INSIDE}

{ Callback types: }
{      GLU_ERROR               100103 }


{***           Tesselation constants           ***}

  GLU_TESS_MAX_COORD     =         1.0e150;
  {$EXTERNALSYM GLU_TESS_MAX_COORD}

{ Property types: }
  GLU_TESS_WINDING_RULE  =         100110;
  {$EXTERNALSYM GLU_TESS_WINDING_RULE}
  GLU_TESS_BOUNDARY_ONLY =         100111;
  {$EXTERNALSYM GLU_TESS_BOUNDARY_ONLY}
  GLU_TESS_TOLERANCE     =         100112;
  {$EXTERNALSYM GLU_TESS_TOLERANCE}

{ Possible winding rules: }
  GLU_TESS_WINDING_ODD          =  100130;
  {$EXTERNALSYM GLU_TESS_WINDING_ODD}
  GLU_TESS_WINDING_NONZERO      =  100131;
  {$EXTERNALSYM GLU_TESS_WINDING_NONZERO}
  GLU_TESS_WINDING_POSITIVE     =  100132;
  {$EXTERNALSYM GLU_TESS_WINDING_POSITIVE}
  GLU_TESS_WINDING_NEGATIVE     =  100133;
  {$EXTERNALSYM GLU_TESS_WINDING_NEGATIVE}
  GLU_TESS_WINDING_ABS_GEQ_TWO  =  100134;
  {$EXTERNALSYM GLU_TESS_WINDING_ABS_GEQ_TWO}

{ Callback types: }
  GLU_TESS_BEGIN     = 100100 ;     { void (*)(GLenum    type)         }
  {$EXTERNALSYM GLU_TESS_BEGIN}
  GLU_TESS_VERTEX    = 100101 ;     { void (*)(void      *data)        }
  {$EXTERNALSYM GLU_TESS_VERTEX}
  GLU_TESS_END       = 100102 ;     { void (*)(void)                   }
  {$EXTERNALSYM GLU_TESS_END}
  GLU_TESS_ERROR     = 100103 ;     { void (*)(GLenum    errno)        }
  {$EXTERNALSYM GLU_TESS_ERROR}
  GLU_TESS_EDGE_FLAG = 100104 ;     { void (*)(GLboolean boundaryEdge) }
  {$EXTERNALSYM GLU_TESS_EDGE_FLAG}
  GLU_TESS_COMBINE   = 100105 ;     { void (*)(GLdouble  coords[3],;
                                                    void      *data[4],;
                                                    GLfloat   weight[4],;
                                                    void      **dataOut)    }
  {$EXTERNALSYM GLU_TESS_COMBINE}

{ Errors: }
  GLU_TESS_ERROR1    = 100151;
  {$EXTERNALSYM GLU_TESS_ERROR1}
  GLU_TESS_ERROR2    = 100152;
  {$EXTERNALSYM GLU_TESS_ERROR2}
  GLU_TESS_ERROR3    = 100153;
  {$EXTERNALSYM GLU_TESS_ERROR3}
  GLU_TESS_ERROR4    = 100154;
  {$EXTERNALSYM GLU_TESS_ERROR4}
  GLU_TESS_ERROR5    = 100155;
  {$EXTERNALSYM GLU_TESS_ERROR5}
  GLU_TESS_ERROR6    = 100156;
  {$EXTERNALSYM GLU_TESS_ERROR6}
  GLU_TESS_ERROR7    = 100157;
  {$EXTERNALSYM GLU_TESS_ERROR7}
  GLU_TESS_ERROR8    = 100158;
  {$EXTERNALSYM GLU_TESS_ERROR8}

  GLU_TESS_MISSING_BEGIN_POLYGON  = GLU_TESS_ERROR1;
  {$EXTERNALSYM GLU_TESS_MISSING_BEGIN_POLYGON}
  GLU_TESS_MISSING_BEGIN_CONTOUR  = GLU_TESS_ERROR2;
  {$EXTERNALSYM GLU_TESS_MISSING_BEGIN_CONTOUR}
  GLU_TESS_MISSING_END_POLYGON    = GLU_TESS_ERROR3;
  {$EXTERNALSYM GLU_TESS_MISSING_END_POLYGON}
  GLU_TESS_MISSING_END_CONTOUR    = GLU_TESS_ERROR4;
  {$EXTERNALSYM GLU_TESS_MISSING_END_CONTOUR}
  GLU_TESS_COORD_TOO_LARGE        = GLU_TESS_ERROR5;
  {$EXTERNALSYM GLU_TESS_COORD_TOO_LARGE}
  GLU_TESS_NEED_COMBINE_CALLBACK  = GLU_TESS_ERROR6;
  {$EXTERNALSYM GLU_TESS_NEED_COMBINE_CALLBACK}

{***           NURBS constants                 ***}

{ Properties: }
  GLU_AUTO_LOAD_MATRIX          =  100200;
  {$EXTERNALSYM GLU_AUTO_LOAD_MATRIX}
  GLU_CULLING                   =  100201;
  {$EXTERNALSYM GLU_CULLING}
  GLU_SAMPLING_TOLERANCE        =  100203;
  {$EXTERNALSYM GLU_SAMPLING_TOLERANCE}
  GLU_DISPLAY_MODE              =  100204;
  {$EXTERNALSYM GLU_DISPLAY_MODE}
  GLU_PARAMETRIC_TOLERANCE      =  100202;
  {$EXTERNALSYM GLU_PARAMETRIC_TOLERANCE}
  GLU_SAMPLING_METHOD           =  100205;
  {$EXTERNALSYM GLU_SAMPLING_METHOD}
  GLU_U_STEP                    =  100206;
  {$EXTERNALSYM GLU_U_STEP}
  GLU_V_STEP                    =  100207;
  {$EXTERNALSYM GLU_V_STEP}

{ Sampling methods: }
  GLU_PATH_LENGTH               =  100215;
  {$EXTERNALSYM GLU_PATH_LENGTH}
  GLU_PARAMETRIC_ERROR          =  100216;
  {$EXTERNALSYM GLU_PARAMETRIC_ERROR}
  GLU_DOMAIN_DISTANCE           =  100217;
  {$EXTERNALSYM GLU_DOMAIN_DISTANCE}

{ Trimming curve types }
  GLU_MAP1_TRIM_2       =  100210;
  {$EXTERNALSYM GLU_MAP1_TRIM_2}
  GLU_MAP1_TRIM_3       =  100211;
  {$EXTERNALSYM GLU_MAP1_TRIM_3}

{ Display modes: }
{      GLU_FILL                100012 }
  GLU_OUTLINE_POLYGON    = 100240;
  {$EXTERNALSYM GLU_OUTLINE_POLYGON}
  GLU_OUTLINE_PATCH      = 100241;
  {$EXTERNALSYM GLU_OUTLINE_PATCH}

{ Callbacks: }
{      GLU_ERROR               100103 }

{ Errors: }
  GLU_NURBS_ERROR1       = 100251;
  {$EXTERNALSYM GLU_NURBS_ERROR1}
  GLU_NURBS_ERROR2       = 100252;
  {$EXTERNALSYM GLU_NURBS_ERROR2}
  GLU_NURBS_ERROR3       = 100253;
  {$EXTERNALSYM GLU_NURBS_ERROR3}
  GLU_NURBS_ERROR4       = 100254;
  {$EXTERNALSYM GLU_NURBS_ERROR4}
  GLU_NURBS_ERROR5       = 100255;
  {$EXTERNALSYM GLU_NURBS_ERROR5}
  GLU_NURBS_ERROR6       = 100256;
  {$EXTERNALSYM GLU_NURBS_ERROR6}
  GLU_NURBS_ERROR7       = 100257;
  {$EXTERNALSYM GLU_NURBS_ERROR7}
  GLU_NURBS_ERROR8       = 100258;
  {$EXTERNALSYM GLU_NURBS_ERROR8}
  GLU_NURBS_ERROR9       = 100259;
  {$EXTERNALSYM GLU_NURBS_ERROR9}
  GLU_NURBS_ERROR10      = 100260;
  {$EXTERNALSYM GLU_NURBS_ERROR10}
  GLU_NURBS_ERROR11      = 100261;
  {$EXTERNALSYM GLU_NURBS_ERROR11}
  GLU_NURBS_ERROR12      = 100262;
  {$EXTERNALSYM GLU_NURBS_ERROR12}
  GLU_NURBS_ERROR13      = 100263;
  {$EXTERNALSYM GLU_NURBS_ERROR13}
  GLU_NURBS_ERROR14      = 100264;
  {$EXTERNALSYM GLU_NURBS_ERROR14}
  GLU_NURBS_ERROR15      = 100265;
  {$EXTERNALSYM GLU_NURBS_ERROR15}
  GLU_NURBS_ERROR16      = 100266;
  {$EXTERNALSYM GLU_NURBS_ERROR16}
  GLU_NURBS_ERROR17      = 100267;
  {$EXTERNALSYM GLU_NURBS_ERROR17}
  GLU_NURBS_ERROR18      = 100268;
  {$EXTERNALSYM GLU_NURBS_ERROR18}
  GLU_NURBS_ERROR19      = 100269;
  {$EXTERNALSYM GLU_NURBS_ERROR19}
  GLU_NURBS_ERROR20      = 100270;
  {$EXTERNALSYM GLU_NURBS_ERROR20}
  GLU_NURBS_ERROR21      = 100271;
  {$EXTERNALSYM GLU_NURBS_ERROR21}
  GLU_NURBS_ERROR22      = 100272;
  {$EXTERNALSYM GLU_NURBS_ERROR22}
  GLU_NURBS_ERROR23      = 100273;
  {$EXTERNALSYM GLU_NURBS_ERROR23}
  GLU_NURBS_ERROR24      = 100274;
  {$EXTERNALSYM GLU_NURBS_ERROR24}
  GLU_NURBS_ERROR25      = 100275;
  {$EXTERNALSYM GLU_NURBS_ERROR25}
  GLU_NURBS_ERROR26      = 100276;
  {$EXTERNALSYM GLU_NURBS_ERROR26}
  GLU_NURBS_ERROR27      = 100277;
  {$EXTERNALSYM GLU_NURBS_ERROR27}
  GLU_NURBS_ERROR28      = 100278;
  {$EXTERNALSYM GLU_NURBS_ERROR28}
  GLU_NURBS_ERROR29      = 100279;
  {$EXTERNALSYM GLU_NURBS_ERROR29}
  GLU_NURBS_ERROR30      = 100280;
  {$EXTERNALSYM GLU_NURBS_ERROR30}
  GLU_NURBS_ERROR31      = 100281;
  {$EXTERNALSYM GLU_NURBS_ERROR31}
  GLU_NURBS_ERROR32      = 100282;
  {$EXTERNALSYM GLU_NURBS_ERROR32}
  GLU_NURBS_ERROR33      = 100283;
  {$EXTERNALSYM GLU_NURBS_ERROR33}
  GLU_NURBS_ERROR34      = 100284;
  {$EXTERNALSYM GLU_NURBS_ERROR34}
  GLU_NURBS_ERROR35      = 100285;
  {$EXTERNALSYM GLU_NURBS_ERROR35}
  GLU_NURBS_ERROR36      = 100286;
  {$EXTERNALSYM GLU_NURBS_ERROR36}
  GLU_NURBS_ERROR37      = 100287;
  {$EXTERNALSYM GLU_NURBS_ERROR37}

{
/****           Backwards compatibility for old tesselator           ****/

typedef GLUtesselator GLUtriangulatorObj;

procedure   gluBeginPolygon( tess: GLUtesselator );

procedure   gluNextContour(  tess: GLUtesselator,
                                 GLenum        type );

procedure   gluEndPolygon(   tess: GLUtesselator );

/* Contours types -- obsolete! */
#define GLU_CW          100120
#define GLU_CCW         100121
#define GLU_INTERIOR    100122
#define GLU_EXTERIOR    100123
#define GLU_UNKNOWN     100124

/* Names without "TESS_" prefix */
#define GLU_BEGIN       GLU_TESS_BEGIN
#define GLU_VERTEX      GLU_TESS_VERTEX
#define GLU_END         GLU_TESS_END
#define GLU_ERROR       GLU_TESS_ERROR
#define GLU_EDGE_FLAG   GLU_TESS_EDGE_FLAG
}

{ GDI support routines for OpenGL ==========================================}

function wglGetProcAddress(ProcName: PChar): Pointer;  stdcall;
  {$EXTERNALSYM wglGetProcAddress}

const
  glu32 = 'glu32.dll';

implementation

procedure glAccum; external opengl32;
procedure glAlphaFunc; external opengl32;
procedure glBegin; external opengl32;
procedure glBitmap; external opengl32;
procedure glBlendFunc; external opengl32;
procedure glCallList; external opengl32;
procedure glCallLists; external opengl32;
procedure glClear; external opengl32;
procedure glClearAccum; external opengl32;
procedure glClearColor; external opengl32;
procedure glClearDepth; external opengl32;
procedure glClearIndex; external opengl32;
procedure glClearStencil; external opengl32;
procedure glClipPlane; external opengl32;
procedure glColor3b; external opengl32;
procedure glColor3bv; external opengl32;
procedure glColor3d; external opengl32;
procedure glColor3dv; external opengl32;
procedure glColor3f; external opengl32;
procedure glColor3fv; external opengl32;
procedure glColor3i; external opengl32;
procedure glColor3iv; external opengl32;
procedure glColor3s; external opengl32;
procedure glColor3sv; external opengl32;
procedure glColor3ub; external opengl32;
procedure glColor3ubv; external opengl32;
procedure glColor3ui; external opengl32;
procedure glColor3uiv; external opengl32;
procedure glColor3us; external opengl32;
procedure glColor3usv; external opengl32;
procedure glColor4b; external opengl32;
procedure glColor4bv; external opengl32;
procedure glColor4d; external opengl32;
procedure glColor4dv; external opengl32;
procedure glColor4f; external opengl32;
procedure glColor4fv; external opengl32;
procedure glColor4i; external opengl32;
procedure glColor4iv; external opengl32;
procedure glColor4s; external opengl32;
procedure glColor4sv; external opengl32;
procedure glColor4ub; external opengl32;
procedure glColor4ubv; external opengl32;
procedure glColor4ui; external opengl32;
procedure glColor4uiv; external opengl32;
procedure glColor4us; external opengl32;
procedure glColor4usv; external opengl32;
procedure glColor(red, green, blue: GLbyte); external opengl32 name 'glColor3b';
procedure glColor(red, green, blue: GLdouble); external opengl32 name 'glColor3d';
procedure glColor(red, green, blue: GLfloat); external opengl32 name 'glColor3f';
procedure glColor(red, green, blue: GLint); external opengl32 name 'glColor3i';
procedure glColor(red, green, blue: GLshort); external opengl32 name 'glColor3s';
procedure glColor(red, green, blue: GLubyte); external opengl32 name 'glColor3ub';
procedure glColor(red, green, blue: GLuint); external opengl32 name 'glColor3ui';
procedure glColor(red, green, blue: GLushort); external opengl32 name 'glColor3us';
procedure glColor(red, green, blue, alpha: GLbyte); external opengl32 name 'glColor4b';
procedure glColor(red, green, blue, alpha: GLdouble); external opengl32 name 'glColor4d';
procedure glColor(red, green, blue, alpha: GLfloat); external opengl32 name 'glColor4f';
procedure glColor(red, green, blue, alpha: GLint); external opengl32 name 'glColor4i';
procedure glColor(red, green, blue, alpha: GLshort); external opengl32 name 'glColor4s';
procedure glColor(red, green, blue, alpha: GLubyte); external opengl32 name 'glColor4ub';
procedure glColor(red, green, blue, alpha: GLuint); external opengl32 name 'glColor4ui';
procedure glColor(red, green, blue, alpha: GLushort); external opengl32 name 'glColor4us';
procedure glColor3(v: PGLbyte); external opengl32 name 'glColor3bv';
procedure glColor3(v: PGLdouble); external opengl32 name 'glColor3dv';
procedure glColor3(v: PGLfloat); external opengl32 name 'glColor3fv';
procedure glColor3(v: PGLint); external opengl32 name 'glColor3iv';
procedure glColor3(v: PGLshort); external opengl32 name 'glColor3sv';
procedure glColor3(v: PGLubyte); external opengl32 name 'glColor3ubv';
procedure glColor3(v: PGLuint); external opengl32 name 'glColor3uiv';
procedure glColor3(v: PGLushort); external opengl32 name 'glColor3usv';
procedure glColor4(v: PGLbyte); external opengl32 name 'glColor4bv';
procedure glColor4(v: PGLdouble); external opengl32 name 'glColor4dv';
procedure glColor4(v: PGLfloat); external opengl32 name 'glColor4fv';
procedure glColor4(v: PGLint); external opengl32 name 'glColor4iv';
procedure glColor4(v: PGLshort); external opengl32 name 'glColor4sv';
procedure glColor4(v: PGLubyte); external opengl32 name 'glColor4ubv';
procedure glColor4(v: PGLuint); external opengl32 name 'glColor4uiv';
procedure glColor4(v: PGLushort); external opengl32 name 'glColor4usv';
procedure glColorMask; external opengl32;
procedure glColorMaterial; external opengl32;
procedure glCopyPixels; external opengl32;
procedure glCullFace; external opengl32;
procedure glDeleteLists; external opengl32;
procedure glDepthFunc; external opengl32;
procedure glDepthMask; external opengl32;
procedure glDepthRange; external opengl32;
procedure glDisable; external opengl32;
procedure glDrawBuffer; external opengl32;
procedure glDrawPixels; external opengl32;
procedure glEdgeFlag; external opengl32;
procedure glEdgeFlagv; external opengl32;
procedure glEnable; external opengl32;
procedure glEnd; external opengl32;
procedure glEndList; external opengl32;
procedure glEvalCoord1d; external opengl32;
procedure glEvalCoord1dv; external opengl32;
procedure glEvalCoord1f; external opengl32;
procedure glEvalCoord1fv; external opengl32;
procedure glEvalCoord2d; external opengl32;
procedure glEvalCoord2dv; external opengl32;
procedure glEvalCoord2f; external opengl32;
procedure glEvalCoord2fv; external opengl32;
procedure glEvalCoord(u: GLdouble); external opengl32 name 'glEvalCoord1d';
procedure glEvalCoord(u: GLfloat); external opengl32 name 'glEvalCoord1f';
procedure glEvalCoord(u,v: GLdouble); external opengl32 name 'glEvalCoord2d';
procedure glEvalCoord(u,v: GLfloat); external opengl32 name 'glEvalCoord2f';
procedure glEvalCoord1(v: PGLdouble); external opengl32 name 'glEvalCoord1dv';
procedure glEvalCoord1(v: PGLfloat); external opengl32 name 'glEvalCoord1fv';
procedure glEvalCoord2(v: PGLdouble); external opengl32 name 'glEvalCoord2dv';
procedure glEvalCoord2(v: PGLfloat); external opengl32 name 'glEvalCoord2fv';
procedure glEvalMesh1; external opengl32;
procedure glEvalMesh2; external opengl32;
procedure glEvalMesh(mode: GLenum; i1, i2: GLint); external opengl32 name 'glEvalMesh1';
procedure glEvalMesh(mode: GLenum; i1, i2, j1, j2: GLint); external opengl32 name 'glEvalMesh2';
procedure glEvalPoint1; external opengl32;
procedure glEvalPoint2; external opengl32;
procedure glEvalPoint(i: GLint); external opengl32 name 'glEvalPoint1';
procedure glEvalPoint(i,j: GLint); external opengl32 name 'glEvalPoint2';
procedure glFeedbackBuffer; external opengl32;
procedure glFinish; external opengl32;
procedure glFlush; external opengl32;
procedure glFogf; external opengl32;
procedure glFogfv; external opengl32;
procedure glFogi; external opengl32;
procedure glFogiv; external opengl32;
procedure glFog(pname: GLenum; param: GLfloat); external opengl32 name 'glFogf';
procedure glFog(pname: GLenum; params: PGLfloat); external opengl32 name 'glFogfv';
procedure glFog(pname: GLenum; param: GLint); external opengl32 name 'glFogi';
procedure glFog(pname: GLenum; params: PGLint); external opengl32 name 'glFogiv';
procedure glFrontFace; external opengl32;
procedure glFrustum; external opengl32;
function  glGenLists; external opengl32;
procedure glGetBooleanv; external opengl32;
procedure glGetClipPlane; external opengl32;
procedure glGetDoublev; external opengl32;
function  glGetError: GLenum; external opengl32;
procedure glGetFloatv; external opengl32;
procedure glGetIntegerv; external opengl32;
procedure glGetLightfv; external opengl32;
procedure glGetLightiv; external opengl32;
procedure glGetLight(light: GLenum; pname: GLenum; params: PGLfloat); external opengl32 name 'glGetLightfv';
procedure glGetLight(light: GLenum; pname: GLenum; params: PGLint); external opengl32 name 'glGetLightiv';
procedure glGetMapdv; external opengl32;
procedure glGetMapfv; external opengl32;
procedure glGetMapiv; external opengl32;
procedure glGetMap(target: GLenum; query: GLenum; v: PGLdouble); external opengl32 name 'glGetMapdv';
procedure glGetMap(target: GLenum; query: GLenum; v: PGLfloat); external opengl32 name 'glGetMapfv';
procedure glGetMap(target: GLenum; query: GLenum; v: PGLint); external opengl32 name 'glGetMapiv';
procedure glGetMaterialfv; external opengl32;
procedure glGetMaterialiv; external opengl32;
procedure glGetMaterial(face: GLenum; pname: GLenum; params: PGLfloat); external opengl32 name 'glGetMaterialfv';
procedure glGetMaterial(face: GLenum; pname: GLenum; params: PGLint); external opengl32 name 'glGetMaterialiv';
procedure glGetPixelMapfv; external opengl32;
procedure glGetPixelMapuiv; external opengl32;
procedure glGetPixelMapusv; external opengl32;
procedure glGetPixelMap(map: GLenum; values: PGLfloat); external opengl32 name 'glGetPixelMapfv';
procedure glGetPixelMap(map: GLenum; values: PGLuint); external opengl32 name 'glGetPixelMapuiv';
procedure glGetPixelMap(map: GLenum; values: PGLushort); external opengl32 name 'glGetPixelMapusv';
procedure glGetPolygonStipple; external opengl32;
function  glGetString; external opengl32;
procedure glGetTexEnvfv; external opengl32;
procedure glGetTexEnviv; external opengl32;
procedure glGetTexEnv(target: GLenum; pname: GLenum; params: PGLfloat); external opengl32 name 'glGetTexEnvfv';
procedure glGetTexEnv(target: GLenum; pname: GLenum; params: PGLint); external opengl32 name 'glGetTexEnviv';
procedure glGetTexGendv; external opengl32;
procedure glGetTexGenfv; external opengl32;
procedure glGetTexGeniv; external opengl32;
procedure glGetTexGen(coord: GLenum; pname: GLenum; params: PGLdouble); external opengl32 name 'glGetTexGendv';
procedure glGetTexGen(coord: GLenum; pname: GLenum; params: PGLfloat); external opengl32 name 'glGetTexGenfv';
procedure glGetTexGen(coord: GLenum; pname: GLenum; params: PGLint); external opengl32 name 'glGetTexGeniv';
procedure glGetTexImage; external opengl32;
procedure glGetTexLevelParameterfv; external opengl32;
procedure glGetTexLevelParameteriv; external opengl32;
procedure glGetTexLevelParameter(target: GLenum; level: GLint; pname: GLenum; params: PGLfloat); external opengl32 name 'glGetTexLevelParameterfv';
procedure glGetTexLevelParameter(target: GLenum; level: GLint; pname: GLenum; params: PGLint); external opengl32 name 'glGetTexLevelParameteriv';
procedure glGetTexParameterfv; external opengl32;
procedure glGetTexParameteriv; external opengl32;
procedure glGetTexParameter(target, pname: GLenum; params: PGLfloat); external opengl32 name 'glGetTexParameterfv';
procedure glGetTexParameter(target, pname: GLenum; params: PGLint); external opengl32 name 'glGetTexParameteriv';
procedure glHint; external opengl32;
procedure glIndexMask; external opengl32;
procedure glIndexd; external opengl32;
procedure glIndexdv; external opengl32;
procedure glIndexf; external opengl32;
procedure glIndexfv; external opengl32;
procedure glIndexi; external opengl32;
procedure glIndexiv; external opengl32;
procedure glIndexs; external opengl32;
procedure glIndexsv; external opengl32;
procedure glIndex(c: GLdouble); external opengl32 name 'glIndexd';
procedure glIndex(c: PGLdouble); external opengl32 name 'glIndexdv';
procedure glIndex(c: GLfloat); external opengl32 name 'glIndexf';
procedure glIndex(c: PGLfloat); external opengl32 name 'glIndexfv';
procedure glIndex(c: GLint); external opengl32 name 'glIndexi';
procedure glIndex(c: PGLint); external opengl32 name 'glIndexiv';
procedure glIndex(c: GLshort); external opengl32 name 'glIndexs';
procedure glIndex(c: PGLshort); external opengl32 name 'glIndexsv';
procedure glInitNames; external opengl32;
function  glIsEnabled; external opengl32;
function  glIsList; external opengl32;
procedure glLightModelf; external opengl32;
procedure glLightModelfv; external opengl32;
procedure glLightModeli; external opengl32;
procedure glLightModeliv; external opengl32;
procedure glLightModel(pname: GLenum; param: GLfloat); external opengl32 name 'glLightModelf';
procedure glLightModel(pname: GLenum; params: PGLfloat); external opengl32 name 'glLightModelfv';
procedure glLightModel(pname: GLenum; param: GLint); external opengl32 name 'glLightModeli';
procedure glLightModel(pname: GLenum; params: PGLint); external opengl32 name 'glLightModeliv';
procedure glLightf; external opengl32;
procedure glLightfv; external opengl32;
procedure glLighti; external opengl32;
procedure glLightiv; external opengl32;
procedure glLight(light, pname: GLenum; param: GLfloat); external opengl32 name 'glLightf';
procedure glLight(light, pname: GLenum; params: PGLfloat); external opengl32 name 'glLightfv';
procedure glLight(light, pname: GLenum; param: GLint); external opengl32 name 'glLighti';
procedure glLight(light, pname: GLenum; params: PGLint); external opengl32 name 'glLightiv';
procedure glLineStipple; external opengl32;
procedure glLineWidth; external opengl32;
procedure glListBase; external opengl32;
procedure glLoadIdentity; external opengl32;
procedure glLoadMatrixd; external opengl32;
procedure glLoadMatrixf; external opengl32;
procedure glLoadMatrix(m: PGLdouble); external opengl32 name 'glLoadMatrixd';
procedure glLoadMatrix(m: PGLfloat); external opengl32 name 'glLoadMatrixf';
procedure glLoadName; external opengl32;
procedure glLogicOp; external opengl32;
procedure glMap1d; external opengl32;
procedure glMap1f; external opengl32;
procedure glMap2d; external opengl32;
procedure glMap2f; external opengl32;
procedure glMap(target: GLenum; u1,u2: GLdouble; stride, order: GLint;
  Points: PGLdouble); external opengl32 name 'glMap1d';
procedure glMap(target: GLenum; u1,u2: GLfloat; stride, order: GLint;
  Points: PGLfloat); external opengl32 name 'glMap1f';
procedure glMap(target: GLenum;
  u1,u2: GLdouble; ustride, uorder: GLint;
  v1,v2: GLdouble; vstride, vorder: GLint; Points: PGLdouble); external opengl32 name 'glMap2d';
procedure glMap(target: GLenum;
  u1,u2: GLfloat; ustride, uorder: GLint;
  v1,v2: GLfloat; vstride, vorder: GLint; Points: PGLfloat); external opengl32 name 'glMap2f';
procedure glMapGrid1d; external opengl32;
procedure glMapGrid1f; external opengl32;
procedure glMapGrid2d; external opengl32;
procedure glMapGrid2f; external opengl32;
procedure glMapGrid(un: GLint; u1, u2: GLdouble); external opengl32 name 'glMapGrid1d';
procedure glMapGrid(un: GLint; u1, u2: GLfloat); external opengl32 name 'glMapGrid1f';
procedure glMapGrid(un: GLint; u1, u2: GLdouble;
                    vn: GLint; v1, v2: GLdouble); external opengl32 name 'glMapGrid2d';
procedure glMapGrid(un: GLint; u1, u2: GLfloat;
                    vn: GLint; v1, v2: GLfloat); external opengl32 name 'glMapGrid2f';
procedure glMaterialf; external opengl32;
procedure glMaterialfv; external opengl32;
procedure glMateriali; external opengl32;
procedure glMaterialiv; external opengl32;
procedure glMaterial(face, pname: GLenum; param: GLfloat); external opengl32 name 'glMaterialf';
procedure glMaterial(face, pname: GLenum; params: PGLfloat); external opengl32 name 'glMaterialfv';
procedure glMaterial(face, pname: GLenum; param: GLint); external opengl32 name 'glMateriali';
procedure glMaterial(face, pname: GLenum; params: PGLint); external opengl32 name 'glMaterialiv';
procedure glMatrixMode; external opengl32;
procedure glMultMatrixd; external opengl32;
procedure glMultMatrixf; external opengl32;
procedure glMultMatrix(m: PGLdouble); external opengl32 name 'glMultMatrixd';
procedure glMultMatrix(m: PGLfloat); external opengl32 name 'glMultMatrixf';
procedure glNewList; external opengl32;
procedure glNormal3b; external opengl32;
procedure glNormal3bv; external opengl32;
procedure glNormal3d; external opengl32;
procedure glNormal3dv; external opengl32;
procedure glNormal3f; external opengl32;
procedure glNormal3fv; external opengl32;
procedure glNormal3i; external opengl32;
procedure glNormal3iv; external opengl32;
procedure glNormal3s; external opengl32;
procedure glNormal3sv; external opengl32;
procedure glNormal(nx, ny, nz: GLbyte); external opengl32 name 'glNormal3b';
procedure glNormal3(v: PGLbyte); external opengl32 name 'glNormal3bv';
procedure glNormal(nx, ny, nz: GLdouble); external opengl32 name 'glNormal3d';
procedure glNormal3(v: PGLdouble); external opengl32 name 'glNormal3dv';
procedure glNormal(nx, ny, nz: GLFloat); external opengl32 name 'glNormal3f';
procedure glNormal3(v: PGLfloat); external opengl32 name 'glNormal3fv';
procedure glNormal(nx, ny, nz: GLint); external opengl32 name 'glNormal3i';
procedure glNormal3(v: PGLint); external opengl32 name 'glNormal3iv';
procedure glNormal(nx, ny, nz: GLshort); external opengl32 name 'glNormal3s';
procedure glNormal3(v: PGLshort); external opengl32 name 'glNormal3sv';
procedure glOrtho; external opengl32;
procedure glPassThrough; external opengl32;
procedure glPixelMapfv; external opengl32;
procedure glPixelMapuiv; external opengl32;
procedure glPixelMapusv; external opengl32;
procedure glPixelMap(map: GLenum; mapsize: GLint; values: PGLfloat); external opengl32 name 'glPixelMapfv';
procedure glPixelMap(map: GLenum; mapsize: GLint; values: PGLuint); external opengl32 name 'glPixelMapuiv';
procedure glPixelMap(map: GLenum; mapsize: GLint; values: PGLushort); external opengl32 name 'glPixelMapusv';
procedure glPixelStoref; external opengl32;
procedure glPixelStorei; external opengl32;
procedure glPixelStore(pname: GLenum; param: GLfloat); external opengl32 name 'glPixelStoref';
procedure glPixelStore(pname: GLenum; param: GLint); external opengl32 name 'glPixelStorei';
procedure glPixelTransferf; external opengl32;
procedure glPixelTransferi; external opengl32;
procedure glPixelTransfer(pname: GLenum; param: GLfloat); external opengl32 name 'glPixelTransferf';
procedure glPixelTransfer(pname: GLenum; param: GLint); external opengl32 name 'glPixelTransferi';
procedure glPixelZoom; external opengl32;
procedure glPointSize; external opengl32;
procedure glPolygonMode; external opengl32;
procedure glPolygonStipple; external opengl32;
procedure glPopAttrib; external opengl32;
procedure glPopMatrix; external opengl32;
procedure glPopName; external opengl32;
procedure glPushAttrib; external opengl32;
procedure glPushMatrix; external opengl32;
procedure glPushName; external opengl32;
procedure glRasterPos2d; external opengl32;
procedure glRasterPos2dv; external opengl32;
procedure glRasterPos2f; external opengl32;
procedure glRasterPos2fv; external opengl32;
procedure glRasterPos2i; external opengl32;
procedure glRasterPos2iv; external opengl32;
procedure glRasterPos2s; external opengl32;
procedure glRasterPos2sv; external opengl32;
procedure glRasterPos3d; external opengl32;
procedure glRasterPos3dv; external opengl32;
procedure glRasterPos3f; external opengl32;
procedure glRasterPos3fv; external opengl32;
procedure glRasterPos3i; external opengl32;
procedure glRasterPos3iv; external opengl32;
procedure glRasterPos3s; external opengl32;
procedure glRasterPos3sv; external opengl32;
procedure glRasterPos4d; external opengl32;
procedure glRasterPos4dv; external opengl32;
procedure glRasterPos4f; external opengl32;
procedure glRasterPos4fv; external opengl32;
procedure glRasterPos4i; external opengl32;
procedure glRasterPos4iv; external opengl32;
procedure glRasterPos4s; external opengl32;
procedure glRasterPos4sv; external opengl32;
procedure glRasterPos(x,y: GLdouble); external opengl32 name 'glRasterPos2d';
procedure glRasterPos2(v: PGLdouble); external opengl32 name 'glRasterPos2dv';
procedure glRasterPos(x,y: GLfloat); external opengl32 name 'glRasterPos2f';
procedure glRasterPos2(v: PGLfloat); external opengl32 name 'glRasterPos2fv';
procedure glRasterPos(x,y: GLint); external opengl32 name 'glRasterPos2i';
procedure glRasterPos2(v: PGLint); external opengl32 name 'glRasterPos2iv';
procedure glRasterPos(x,y: GLshort); external opengl32 name 'glRasterPos2s';
procedure glRasterPos2(v: PGLshort); external opengl32 name 'glRasterPos2sv';
procedure glRasterPos(x,y,z: GLdouble); external opengl32 name 'glRasterPos3d';
procedure glRasterPos3(v: PGLdouble); external opengl32 name 'glRasterPos3dv';
procedure glRasterPos(x,y,z: GLfloat); external opengl32 name 'glRasterPos3f';
procedure glRasterPos3(v: PGLfloat); external opengl32 name 'glRasterPos3fv';
procedure glRasterPos(x,y,z: GLint); external opengl32 name 'glRasterPos3i';
procedure glRasterPos3(v: PGLint); external opengl32 name 'glRasterPos3iv';
procedure glRasterPos(x,y,z: GLshort); external opengl32 name 'glRasterPos3s';
procedure glRasterPos3(v: PGLshort); external opengl32 name 'glRasterPos3sv';
procedure glRasterPos(x,y,z,w: GLdouble); external opengl32 name 'glRasterPos4d';
procedure glRasterPos4(v: PGLdouble); external opengl32 name 'glRasterPos4dv';
procedure glRasterPos(x,y,z,w: GLfloat); external opengl32 name 'glRasterPos4f';
procedure glRasterPos4(v: PGLfloat); external opengl32 name 'glRasterPos4fv';
procedure glRasterPos(x,y,z,w: GLint); external opengl32 name 'glRasterPos4i';
procedure glRasterPos4(v: PGLint); external opengl32 name 'glRasterPos4iv';
procedure glRasterPos(x,y,z,w: GLshort); external opengl32 name 'glRasterPos4s';
procedure glRasterPos4(v: PGLshort); external opengl32 name 'glRasterPos4sv';
procedure glReadBuffer; external opengl32;
procedure glReadPixels; external opengl32;
procedure glRectd; external opengl32;
procedure glRectdv; external opengl32;
procedure glRectf; external opengl32;
procedure glRectfv; external opengl32;
procedure glRecti; external opengl32;
procedure glRectiv; external opengl32;
procedure glRects; external opengl32;
procedure glRectsv; external opengl32;
procedure glRect(x1, y1, x2, y2: GLdouble); external opengl32 name 'glRectd';
procedure glRect(v1, v2: PGLdouble); external opengl32 name 'glRectdv';
procedure glRect(x1, y1, x2, y2: GLfloat); external opengl32 name 'glRectf';
procedure glRect(v1, v2: PGLfloat); external opengl32 name 'glRectfv';
procedure glRect(x1, y1, x2, y2: GLint); external opengl32 name 'glRecti';
procedure glRect(v1, v2: PGLint); external opengl32 name 'glRectiv';
procedure glRect(x1, y1, x2, y2: GLshort); external opengl32 name 'glRects';
procedure glRect(v1, v2: PGLshort); external opengl32 name 'glRectsv';
function  glRenderMode; external opengl32;
procedure glRotated; external opengl32;
procedure glRotatef; external opengl32;
procedure glRotate(angle, x,y,z: GLdouble); external opengl32 name 'glRotated';
procedure glRotate(angle, x,y,z: GLfloat); external opengl32 name 'glRotatef';
procedure glScaled; external opengl32;
procedure glScalef; external opengl32;
procedure glScale(x,y,z: GLdouble); external opengl32 name 'glScaled';
procedure glScale(x,y,z: GLfloat); external opengl32 name 'glScalef';
procedure glScissor; external opengl32;
procedure glSelectBuffer; external opengl32;
procedure glShadeModel; external opengl32;
procedure glStencilFunc; external opengl32;
procedure glStencilMask; external opengl32;
procedure glStencilOp; external opengl32;
procedure glTexCoord1d; external opengl32;
procedure glTexCoord1dv; external opengl32;
procedure glTexCoord1f; external opengl32;
procedure glTexCoord1fv; external opengl32;
procedure glTexCoord1i; external opengl32;
procedure glTexCoord1iv; external opengl32;
procedure glTexCoord1s; external opengl32;
procedure glTexCoord1sv; external opengl32;
procedure glTexCoord2d; external opengl32;
procedure glTexCoord2dv; external opengl32;
procedure glTexCoord2f; external opengl32;
procedure glTexCoord2fv; external opengl32;
procedure glTexCoord2i; external opengl32;
procedure glTexCoord2iv; external opengl32;
procedure glTexCoord2s; external opengl32;
procedure glTexCoord2sv; external opengl32;
procedure glTexCoord3d; external opengl32;
procedure glTexCoord3dv; external opengl32;
procedure glTexCoord3f; external opengl32;
procedure glTexCoord3fv; external opengl32;
procedure glTexCoord3i; external opengl32;
procedure glTexCoord3iv; external opengl32;
procedure glTexCoord3s; external opengl32;
procedure glTexCoord3sv; external opengl32;
procedure glTexCoord4d; external opengl32;
procedure glTexCoord4dv; external opengl32;
procedure glTexCoord4f; external opengl32;
procedure glTexCoord4fv; external opengl32;
procedure glTexCoord4i; external opengl32;
procedure glTexCoord4iv; external opengl32;
procedure glTexCoord4s; external opengl32;
procedure glTexCoord4sv; external opengl32;
procedure glTexCoord(s: GLdouble); external opengl32 name 'glTexCoord1d';
procedure glTexCoord1(v: PGLdouble); external opengl32 name 'glTexCoord1dv';
procedure glTexCoord(s: GLfloat); external opengl32 name 'glTexCoord1f';
procedure glTexCoord1(v: PGLfloat); external opengl32 name 'glTexCoord1fv';
procedure glTexCoord(s: GLint); external opengl32 name 'glTexCoord1i';
procedure glTexCoord1(v: PGLint); external opengl32 name 'glTexCoord1iv';
procedure glTexCoord(s: GLshort); external opengl32 name 'glTexCoord1s';
procedure glTexCoord1(v: PGLshort); external opengl32 name 'glTexCoord1sv';
procedure glTexCoord(s,t: GLdouble); external opengl32 name 'glTexCoord2d';
procedure glTexCoord2(v: PGLdouble); external opengl32 name 'glTexCoord2dv';
procedure glTexCoord(s,t: GLfloat); external opengl32 name 'glTexCoord2f';
procedure glTexCoord2(v: PGLfloat); external opengl32 name 'glTexCoord2fv';
procedure glTexCoord(s,t: GLint); external opengl32 name 'glTexCoord2i';
procedure glTexCoord2(v: PGLint); external opengl32 name 'glTexCoord2iv';
procedure glTexCoord(s,t: GLshort); external opengl32 name 'glTexCoord2s';
procedure glTexCoord2(v: PGLshort); external opengl32 name 'glTexCoord2sv';
procedure glTexCoord(s,t,r: GLdouble); external opengl32 name 'glTexCoord3d';
procedure glTexCoord3(v: PGLdouble); external opengl32 name 'glTexCoord3dv';
procedure glTexCoord(s,t,r: GLfloat); external opengl32 name 'glTexCoord3f';
procedure glTexCoord3(v: PGLfloat); external opengl32 name 'glTexCoord3fv';
procedure glTexCoord(s,t,r: GLint); external opengl32 name 'glTexCoord3i';
procedure glTexCoord3(v: PGLint); external opengl32 name 'glTexCoord3iv';
procedure glTexCoord(s,t,r: GLshort); external opengl32 name 'glTexCoord3s';
procedure glTexCoord3(v: PGLshort); external opengl32 name 'glTexCoord3sv';
procedure glTexCoord(s,t,r,q: GLdouble); external opengl32 name 'glTexCoord4d';
procedure glTexCoord4(v: PGLdouble); external opengl32 name 'glTexCoord4dv';
procedure glTexCoord(s,t,r,q: GLfloat); external opengl32 name 'glTexCoord4f';
procedure glTexCoord4(v: PGLfloat); external opengl32 name 'glTexCoord4fv';
procedure glTexCoord(s,t,r,q: GLint); external opengl32 name 'glTexCoord4i';
procedure glTexCoord4(v: PGLint); external opengl32 name 'glTexCoord4iv';
procedure glTexCoord(s,t,r,q: GLshort); external opengl32 name 'glTexCoord4s';
procedure glTexCoord4(v: PGLshort); external opengl32 name 'glTexCoord4sv';
procedure glTexEnvf; external opengl32;
procedure glTexEnvfv; external opengl32;
procedure glTexEnvi; external opengl32;
procedure glTexEnviv; external opengl32;
procedure glTexEnv(target, pname: GLenum; param: GLfloat); external opengl32 name 'glTexEnvf';
procedure glTexEnv(target, pname: GLenum; params: PGLfloat); external opengl32 name 'glTexEnvfv';
procedure glTexEnv(target, pname: GLenum; param: GLint); external opengl32 name 'glTexEnvi';
procedure glTexEnv(target, pname: GLenum; params: PGLint); external opengl32 name 'glTexEnviv';
procedure glTexGend; external opengl32;
procedure glTexGendv; external opengl32;
procedure glTexGenf; external opengl32;
procedure glTexGenfv; external opengl32;
procedure glTexGeni; external opengl32;
procedure glTexGeniv; external opengl32;
procedure glTexGen(coord, pname: GLenum; param: GLdouble); external opengl32 name 'glTexGend';
procedure glTexGen(coord, pname: GLenum; params: PGLdouble); external opengl32 name 'glTexGendv';
procedure glTexGen(coord, pname: GLenum; param: GLfloat); external opengl32 name 'glTexGenf';
procedure glTexGen(coord, pname: GLenum; params: PGLfloat); external opengl32 name 'glTexGenfv';
procedure glTexGen(coord, pname: GLenum; param: GLint); external opengl32 name 'glTexGeni';
procedure glTexGen(coord, pname: GLenum; params: PGLint); external opengl32 name 'glTexGeniv';
procedure glTexImage1D; external opengl32;
procedure glTexImage2D; external opengl32;
procedure glTexParameterf; external opengl32;
procedure glTexParameterfv; external opengl32;
procedure glTexParameteri; external opengl32;
procedure glTexParameteriv; external opengl32;
procedure glTexParameter(target, pname: GLenum; param: GLfloat); external opengl32 name 'glTexParameterf';
procedure glTexParameter(target, pname: GLenum; params: PGLfloat); external opengl32 name 'glTexParameterfv';
procedure glTexParameter(target, pname: GLenum; param: GLint); external opengl32 name 'glTexParameteri';
procedure glTexParameter(target, pname: GLenum; params: PGLint); external opengl32 name 'glTexParameteriv';
procedure glTranslated; external opengl32;
procedure glTranslatef; external opengl32;
procedure glTranslate(x,y,z: GLdouble); external opengl32 name 'glTranslated';
procedure glTranslate(x,y,z: GLfloat); external opengl32 name 'glTranslatef';
procedure glVertex2d; external opengl32;
procedure glVertex2dv; external opengl32;
procedure glVertex2f; external opengl32;
procedure glVertex2fv; external opengl32;
procedure glVertex2i; external opengl32;
procedure glVertex2iv; external opengl32;
procedure glVertex2s; external opengl32;
procedure glVertex2sv; external opengl32;
procedure glVertex3d; external opengl32;
procedure glVertex3dv; external opengl32;
procedure glVertex3f; external opengl32;
procedure glVertex3fv; external opengl32;
procedure glVertex3i; external opengl32;
procedure glVertex3iv; external opengl32;
procedure glVertex3s; external opengl32;
procedure glVertex3sv; external opengl32;
procedure glVertex4d; external opengl32;
procedure glVertex4dv; external opengl32;
procedure glVertex4f; external opengl32;
procedure glVertex4fv; external opengl32;
procedure glVertex4i; external opengl32;
procedure glVertex4iv; external opengl32;
procedure glVertex4s; external opengl32;
procedure glVertex4sv; external opengl32;
procedure glVertex(x,y: GLdouble); external opengl32 name 'glVertex2d';
procedure glVertex2(v: PGLdouble); external opengl32 name 'glVertex2dv';
procedure glVertex(x,y: GLfloat); external opengl32 name 'glVertex2f';
procedure glVertex2(v: PGLfloat); external opengl32 name 'glVertex2fv';
procedure glVertex(x,y: GLint); external opengl32 name 'glVertex2i';
procedure glVertex2(v: PGLint); external opengl32 name 'glVertex2iv';
procedure glVertex(x,y: GLshort); external opengl32 name 'glVertex2s';
procedure glVertex2(v: PGLshort); external opengl32 name 'glVertex2sv';
procedure glVertex(x,y,z: GLdouble); external opengl32 name 'glVertex3d';
procedure glVertex3(v: PGLdouble); external opengl32 name 'glVertex3dv';
procedure glVertex(x,y,z: GLfloat); external opengl32 name 'glVertex3f';
procedure glVertex3(v: PGLfloat); external opengl32 name 'glVertex3fv';
procedure glVertex(x,y,z: GLint); external opengl32 name 'glVertex3i';
procedure glVertex3(v: PGLint); external opengl32 name 'glVertex3iv';
procedure glVertex(x,y,z: GLshort); external opengl32 name 'glVertex3s';
procedure glVertex3(v: PGLshort); external opengl32 name 'glVertex3sv';
procedure glVertex(x,y,z,w: GLdouble); external opengl32 name 'glVertex4d';
procedure glVertex4(v: PGLdouble); external opengl32 name 'glVertex4dv';
procedure glVertex(x,y,z,w: GLfloat); external opengl32 name 'glVertex4f';
procedure glVertex4(v: PGLfloat); external opengl32 name 'glVertex4fv';
procedure glVertex(x,y,z,w: GLint); external opengl32 name 'glVertex4i';
procedure glVertex4(v: PGLint); external opengl32 name 'glVertex4iv';
procedure glVertex(x,y,z,w: GLshort); external opengl32 name 'glVertex4s';
procedure glVertex4(v: PGLshort); external opengl32 name 'glVertex4sv';
procedure glViewport; external opengl32;

function wglGetProcAddress;    external opengl32;

{ OpenGL Utility routines (glu.h) =======================================}

function gluErrorString;                     external glu32;
function gluErrorUnicodeStringEXT;           external glu32;
function gluGetString;                       external glu32;
procedure gluLookAt;                         external glu32;
procedure gluOrtho2D;                        external glu32;
procedure gluPerspective;                    external glu32;
procedure gluPickMatrix;                     external glu32;
function  gluProject;                        external glu32;
function  gluUnProject;                      external glu32;
function  gluScaleImage;                     external glu32;
function  gluBuild1DMipmaps;                 external glu32;
function  gluBuild2DMipmaps;                 external glu32;
function  gluNewQuadric;                     external glu32;
procedure gluDeleteQuadric;                  external glu32;
procedure gluQuadricNormals;                 external glu32;
procedure gluQuadricTexture;                 external glu32;
procedure gluQuadricOrientation;             external glu32;
procedure gluQuadricDrawStyle;               external glu32;
procedure gluCylinder;                       external glu32;
procedure gluDisk;                           external glu32;
procedure gluPartialDisk;                    external glu32;
procedure gluSphere;                         external glu32;
procedure gluQuadricCallback;                external glu32;

function gluNewTess                         ;external glu32;
procedure gluDeleteTess                     ;external glu32;
procedure gluTessBeginPolygon               ;external glu32;
procedure gluTessBeginContour               ;external glu32;
procedure gluTessVertex                     ;external glu32;
procedure gluTessEndContour                 ;external glu32;
procedure gluTessEndPolygon                 ;external glu32;
procedure gluTessProperty                   ;external glu32;
procedure gluTessNormal                     ;external glu32;
procedure gluTessCallback                   ;external glu32;

function gluNewNurbsRenderer                ;external glu32;
procedure gluDeleteNurbsRenderer            ;external glu32;
procedure gluBeginSurface                   ;external glu32;
procedure gluBeginCurve                     ;external glu32;
procedure gluEndCurve                       ;external glu32;
procedure gluEndSurface                     ;external glu32;
procedure gluBeginTrim                      ;external glu32;
procedure gluEndTrim                        ;external glu32;
procedure gluPwlCurve                       ;external glu32;
procedure gluNurbsCurve                     ;external glu32;
procedure gluNurbsSurface                   ;external glu32;
procedure gluLoadSamplingMatrices           ;external glu32;
procedure gluNurbsProperty                  ;external glu32;
procedure gluGetNurbsProperty               ;external glu32;
procedure gluNurbsCallback                  ;external glu32;


begin
  Set8087CW($133F);
end.
