unit Glaux;

interface

uses Windows,Opengl;

type
	TAUX_RGBImageRec= record
		sizeX, sizeY: GLint;
		data: pointer;
	end;
	PTAUX_RGBImageRec= ^TAUX_RGBImageRec;

function auxDIBImageLoadA(const dibfile: PChar): PTAUX_RGBImageRec; stdcall;
procedure auxWireSphere(value: GLdouble);stdcall;
procedure auxSolidSphere(value: GLdouble);stdcall;
procedure auxWireCube(value: GLdouble);stdcall;
procedure auxSolidCube(value: GLdouble);stdcall;
procedure auxWireBox(value,value1,value2: GLdouble);stdcall;
procedure auxSolidBox(value,value1,value2: GLdouble);stdcall;
procedure auxWireTorus(value,value1: GLdouble);stdcall;
procedure auxSolidTorus(value,value1: GLdouble);stdcall;
procedure auxWireCylinder(value,value1: GLdouble);stdcall;
procedure auxSolidCylinder(value,value1: GLdouble);stdcall;
procedure auxWireIcosahedron(value: GLdouble);stdcall;
procedure auxSolidIcosahedron(value: GLdouble);stdcall;
procedure auxWireOctahedron(value: GLdouble);stdcall;
procedure auxSolidOctahedron(value: GLdouble);stdcall;
procedure auxWireTetrahedron(value: GLdouble);stdcall;
procedure auxSolidTetrahedron(value: GLdouble);stdcall;
procedure auxWireDodecahedron(value: GLdouble);stdcall;
procedure auxSolidDodecahedron(value: GLdouble);stdcall;
procedure auxWireCone(value,value1: GLdouble);stdcall;
procedure auxSolidCone(value,value1: GLdouble);stdcall;
procedure auxWireTeapot(value: GLdouble);stdcall;
procedure auxSolidTeapot(value: GLdouble);stdcall;

const
	glaux1 = 'glaux.dll';

implementation

function auxDIBImageLoadA; external glaux1;
procedure auxWireSphere;external glaux1;
procedure auxSolidSphere;external glaux1;
procedure auxWireCube;external glaux1;
procedure auxSolidCube;external glaux1;
procedure auxWireBox;external glaux1;
procedure auxSolidBox;external glaux1;
procedure auxWireTorus;external glaux1;
procedure auxSolidTorus;external glaux1;
procedure auxWireCylinder;external glaux1;
procedure auxSolidCylinder;external glaux1;
procedure auxWireIcosahedron;external glaux1;
procedure auxSolidIcosahedron;external glaux1;
procedure auxWireOctahedron;external glaux1;
procedure auxSolidOctahedron;external glaux1;
procedure auxWireTetrahedron;external glaux1;
procedure auxSolidTetrahedron;external glaux1;
procedure auxWireDodecahedron;external glaux1;
procedure auxSolidDodecahedron;external glaux1;
procedure auxWireCone;external glaux1;
procedure auxSolidCone;external glaux1;
procedure auxWireTeapot;external glaux1;
procedure auxSolidTeapot;external glaux1;


end.
