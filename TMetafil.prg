#include "FiveWin.ch"
#include "Struct.ch"

#define MM_ANISOTROPIC         8

#define SW_HIDE                0
#define SW_SHOWNA              8

#define SHADOW_DEEP            5
#define SHADOW_WIDTH           5

#ifdef __XPP__
   #define Super ::TControl
   #define New   _New
#endif

//----------------------------------------------------------------------------//

CLASS TMetaFile FROM TControl

   DATA   hMeta
   DATA   oPen
   DATA   nWidth, nHeight, nXorig, nYorig, nXZoom, nYZoom
   DATA   lZoom, lShadow
   DATA   lEMF AS LOGICAL
   DATA   hDC32

   CLASSDATA lRegistered AS LOGICAL

   METHOD New( nTop, nLeft, nWidth, nHeight, cMetaFile, oWnd,;
               nClrFore, nClrBack ) CONSTRUCTOR

   METHOD Redefine( nId, cMetaFile, oWnd, nClrFore, nClrBack ) CONSTRUCTOR

   METHOD Display() INLINE ::BeginPaint(), ::Paint(), ::EndPaint(), 0
   METHOD Paint()

   METHOD SetFile(cFile)

   METHOD Shadow()

   METHOD End()

   METHOD ZoomIn()  INLINE IIF(!::lZoom, (::nWidth  /= ::nXZoom ,;
                                          ::nHeight /= ::nYZoom ,;
                                          ::lZoom   :=      .T. ,;
                                          ::Refresh()), )
   METHOD ZoomOut() INLINE IIF(::lZoom , (::nWidth  *= ::nXZoom ,;
                                          ::nHeight *= ::nYZoom ,;
                                          ::lZoom   := .F.      ,;
                                          ::nXorig  := 0        ,;
                                          ::nYorig  := 0        ,;
                                          ::Refresh()), )

   METHOD SetZoomFactor(nXFactor, nYFactor)

   METHOD SetOrg(nX,nY)    INLINE iif(nX != NIL, ::nXorig := nX ,) ,;
                                  iif(nY != NIL, ::nYorig := nY ,)

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, cMetaFile, oWnd,;
            nClrFore, nClrBack,nLogWidth, nLogHeight ) CLASS TMetaFile

   #ifdef __XPP__
      #undef New
   #endif

   DEFAULT nWidth := 100, nHeight := 100, oWnd := GetWndDefault()

   ::nTop     = nTop
   ::nLeft    = nLeft
   ::nBottom  = nTop + nHeight - 1
   ::nRight   = nLeft + nWidth - 1
   ::cCaption = cMetaFile
   ::oWnd     = oWnd
   ::nStyle   = nOr( WS_CHILD, WS_BORDER, WS_VISIBLE )
   ::nWidth   = nLogWidth
   ::nHeight  = nLogHeight
   ::lZoom    = .F.
   ::lShadow  = .T.
   ::nXorig   = 0
   ::nYorig   = 0
   ::hMeta    = 0
   ::nXZoom   = 2
   ::nYZoom   = 4

   #ifdef __XPP__
      DEFAULT ::lRegistered := .f.
   #endif

   ::Register()

   ::SetColor( nClrFore, nClrBack )

   if ::lShadow
     DEFINE PEN ::oPen WIDTH SHADOW_WIDTH
   endif

   if oWnd:lVisible
      ::Create()
      ::Default()
      ::lVisible = .t.
      oWnd:AddControl( Self )
   else
      oWnd:DefControl( Self )
      ::lVisible  = .f.
   endif

// ::lEMF = !IsWinNT()
   ::lEMF = .T.

return Self

//----------------------------------------------------------------------------//

METHOD Redefine( nId, cMetaFile, oWnd, nClrFore, nClrBack ) CLASS TMetaFile

   DEFAULT oWnd := GetWndDefault()

   ::nId      = nId
   ::cCaption = cMetaFile
   ::oWnd     = oWnd
   ::nWidth   = 100
   ::nHeight  = 100
   ::hMeta    = 0
   ::lShadow  = .t.

   #ifdef __XPP__
      DEFAULT ::lRegistered := .f.
   #endif

   ::Register()

   ::SetColor( nClrFore, nClrBack )

   oWnd:DefControl( Self )

   ::lEMF  = .T.

return Self

//----------------------------------------------------------------------------//

METHOD Paint() CLASS TMetaFile

   local oRect := ::GetRect()

   IF ::hMeta == 0
        IF file(::cCaption)
           IF !::lEMF
              ::hMeta := GetMetaFile( ::cCaption )
           ELSE
              ::hMeta := Wmf2Emf( ::cCaption )

              IF empty( ::hMeta )
                 ::hMeta := GetMetaFile( ::cCaption )
                 ::lEMF := .F.
              ELSE
                 ::hDC32 = GETDC32( ::hWnd )
              ENDIF
           ENDIF
        ELSEIF !empty(::cCaption)
         Alert( "Could not find the Metafile," + CRLF + "please check your TEMP environment variable" )
        ENDIF
   ENDIF

   IF ::hMeta != 0
        ::Shadow(.T.)

        IF !::lEMF
           SetWindowOrg(::hDC, ::nXorig, ::nYorig)
           SetMapMode( ::hDC, MM_ANISOTROPIC )
           SetWindowExt( ::hDC, ::nWidth, ::nHeight )
           SetViewportExt( ::hDC, oRect:nRight - oRect:nLeft, oRect:nBottom - oRect:nTop )

           CursorWait()
           PlayMetaFile( ::hDC, ::hMeta )
           CursorArrow()
        ELSE
           SetWOrg32(::hDC32, ::nXorig, ::nYorig)
           SetMMode32( ::hDC32, MM_ANISOTROPIC )
           SetWExt32( ::hDC32, ::nWidth, ::nHeight )
           SetVExt32( ::hDC32, oRect:nRight - oRect:nLeft - 2,;
                           oRect:nBottom - oRect:nTop - 2 )
           PlayEMF( ::hDC32, ::hMeta )
        ENDIF
   ENDIF

return nil

//----------------------------------------------------------------------------//

METHOD SetFile(cFile) CLASS TMetaFile

   if file(cFile)
      ::cCaption = cFile
   else
      ::cCaption = ""
   endif

   if ::hMeta != 0

      if ::lEMF
         DeleteEMF( ::hMeta )
      else
         DeleteMetafile( ::hMeta )
      endif

      ::hMeta = 0

   endif

return nil

//----------------------------------------------------------------------------//

METHOD Shadow() CLASS TMetaFile

     if !::lShadow
        return nil
     endif

     ::oWnd:GetDC()

     MoveTo( ::oWnd:hDC              ,;
          ::nLeft + SHADOW_DEEP   ,;
          ::nBottom )
     LineTo( ::oWnd:hDC              ,;
          ::nRight                ,;
          ::nBottom               ,;
          ::oPen:hPen )
     MoveTo( ::oWnd:hDC              ,;
          ::nRight                ,;
          ::nTop + SHADOW_DEEP )
     LineTo( ::oWnd:hDC              ,;
          ::nRight                ,;
          ::nBottom               ,;
          ::oPen:hPen )

     ::oWnd:ReleaseDC()

return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TMetaFile

   if ::hMeta != 0

      if ::lEMF
         DeleteEMF( ::hMeta )
      else
         DeleteMetafile( ::hMeta )
      endif

      ::hMeta = 0

   endif

   if ::lShadow
      ::oPen:End()
   endif

   Super:End()

return nil

//----------------------------------------------------------------------------//

METHOD SetZoomFactor( nX, nY ) CLASS TMetafile

   if ::lZoom
      ::nWidth  *= ::nXZoom
      ::nHeight *= ::nYZoom
   endif

   ::nXZoom := nX
   ::nYZoom := nY

   if ::lZoom
      ::nWidth  /= ::nXZoom
      ::nHeight /= ::nYZoom
      ::Refresh()
   endif

return NIL

//----------------------------------------------------------------------------//

#command DLL32 [<static: STATIC>] FUNCTION <FuncName>( [<uParam1> AS <type1> [,<uParamN> AS <typeN>]] );
               AS <return> [<pascal: PASCAL>] FROM <DllFunc> LIB <DllName>;
                                                                        ;
      => [<static>] function <FuncName>( [NOREF( <uParam1> )] [,NOREF( <uParamN> )] );
       ;                local hDLL := LoadLib32( <(DllName)> )          ;
       ;                local cFarProc                                  ;
       ;                local uResult                                   ;
       ;                if hDLL != 0                                    ;
       ;                    cFarProc := GetProc32( hDLL, <(DllFunc)>, [<.pascal.>], <return> [,<type1>] [,<typeN>] );
       ;                    uResult := CallDLL32( cFarProc [,<uParam1>] [,<uParamN>] );
       ;                    FreeLib32( hDLL )                           ;
       ;                end                                             ;
       ;                return uResult


DLL32 STATIC FUNCTION WMF2EMF( cWMF AS LPSTR ) AS LONG;
      PASCAL FROM "Wmf2Emf" LIB "emf.dll"

DLL32 STATIC FUNCTION PLAYEMF( hDC AS LONG, hEMF AS LONG ) AS BOOL;
      PASCAL FROM "PlayEMF" LIB "emf.dll"

DLL32 FUNCTION SETWORG32( hDC AS LONG, nX AS LONG, nY AS LONG, cPoint AS LPSTR ) AS BOOL;
      PASCAL FROM "SetWindowOrgEx" LIB "gdi32.dll"

DLL32 FUNCTION SETMMODE32( hDC AS LONG, nMapMode AS LONG ) AS LONG;
      PASCAL FROM "SetMapMode" LIB "gdi32.dll"

DLL32 FUNCTION SETWEXT32( hDC AS LONG, nX AS LONG, nY AS LONG, cSize AS LPSTR ) AS BOOL;
      PASCAL FROM "SetWindowExtEx" LIB "gdi32.dll"

DLL32 FUNCTION SETVEXT32( hDC AS LONG, nXExtent AS LONG, nYExtent AS LONG, cSize AS LPSTR ) AS BOOL;
      PASCAL FROM "SetViewportExtEx" LIB "gdi32.dll"

//DLL32 FUNCTION PLAYEMF( hDC AS LONG, hEMF AS LONG, cRect AS LPSTR ) AS BOOL;
//      PASCAL FROM "PlayEnhMetaFile" LIB "gdi32.dll"

DLL32 STATIC FUNCTION GETDC32( hWnd AS LONG ) AS LONG;
      PASCAL FROM "GetDC" LIB "user32.dll"

DLL32 STATIC FUNCTION DELETEEMF( hEMF AS LONG ) AS BOOL;
      PASCAL FROM "DeleteEMF" LIB "emf.dll"

//----------------------------------------------------------------------------//


