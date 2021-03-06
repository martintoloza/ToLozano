/*
旼 Programa 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
�   Aplication: Preview for class TReport                                  �
�         File: RPREVIEW.PRG                                               �
�       Author: Ignacio Ortiz de Z＄iga Echeverr죂                         �
�          CIS: Ignacio Ortiz (100042,3051)                                �
�     Internet: http://ourworld.compuserve.com/homepages/Ignacio_Ortiz     �
�         Date: 09/28/94                                                   �
�         Time: 20:20:07                                                   �
�    Copyright: 1994 by Ortiz de Zu쨒ga, S.L.                              �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
*/

#include "FiveWin.ch"

#define DEVICE      oWnd:cargo

#define GO_POS      0
#define GO_UP       1
#define GO_DOWN     2
#define GO_LEFT     1
#define GO_RIGHT    2
#define GO_PAGE    .T.

#define VSCROLL_RANGE  20*nZFactor
#define HSCROLL_RANGE  20*nZFactor

#define TXT_FIRST    LoadString( GetResources(), 07 )
#define TXT_PREVIOUS LoadString( GetResources(), 08 )
#define TXT_NEXT     LoadString( GetResources(), 09 )
#define TXT_LAST     LoadString( GetResources(), 10 )
#define TXT_ZOOM     LoadString( GetResources(), 11 )
#define TXT_UNZOOM   LoadString( GetResources(), 12 )
#define TXT_TWOPAGES LoadString( GetResources(), 13 )
#define TXT_ONEPAGE  LoadString( GetResources(), 14 )
#define TXT_PRINT    LoadString( GetResources(), 15 )
#define TXT_EXIT     LoadString( GetResources(), 16 )
#define TXT_FILE     LoadString( GetResources(), 17 )
#define TXT_PAGE     LoadString( GetResources(), 18 )
#define TXT_PREVIEW  LoadString( GetResources(), 03 )
#define TXT_PAGENUM  LoadString( GetResources(), 19 )

#define TXT_A_WINDOW_PREVIEW_IS_ALLREADY_RUNNING ;
        LoadString( GetResources(), 20 )
#define TXT_GOTO_FIRST_PAGE ;
        LoadString( GetResources(), 21 )
#define TXT_GOTO_PREVIOUS_PAGE ;
        LoadString( GetResources(), 22 )
#define TXT_GOTO_NEXT_PAGE ;
        LoadString( GetResources(), 23 )
#define TXT_GOTO_LAST_PAGE ;
        LoadString( GetResources(), 24 )
#define TXT_ZOOM_THE_PREVIEW ;
        LoadString( GetResources(), 25 )
#define TXT_UNZOOM_THE_PREVIEW ;
        LoadString( GetResources(), 26 )
#define TXT_PREVIEW_ON_TWO_PAGES ;
        LoadString( GetResources(), 27 )
#define TXT_PREVIEW_ON_ONE_PAGE ;
        LoadString( GetResources(), 28 )
#define TXT_PRINT_CURRENT_PAGE ;
        LoadString( GetResources(), 29 )
#define TXT_EXIT_PREVIEW ;
        LoadString( GetResources(), 30 )
#define TXT_ZOOM_FACTOR ;
        "Set the Zoom factor"

#define TXT_ACPLESS   LoadString( GetResources(), 31 )
#define TXT_ACPMORE   LoadString( GetResources(), 32 )
#define TXT_ACPLEFT   LoadString( GetResources(), 33 )
#define TXT_ACPRIGHT  LoadString( GetResources(), 34 )
#define TXT_ACPTOP    LoadString( GetResources(), 35 )
#define TXT_ACPBOTTOM LoadString( GetResources(), 36 )

STATIC oWnd, oMeta1, oMeta2,;
       oPage, oTwoPages, oZoom, oMenuZoom, oMenuTwoPages,;
       oMenuUnZoom, oMenuOnePage, oFactor, cResFile

STATIC aFactor

STATIC nPage, nZFactor

STATIC lTwoPages, lZoom

static nXOrig, nYOrig

//----------------------------------------------------------------------------//

FUNCTION RPreview( oDevice )

     LOCAL aFiles := oDevice:aMeta
     LOCAL hOldRes := GetResources()
     LOCAL oSay
     LOCAL nFor
     local oWndMain := WndMain(), oIcon, oBar, oCursor, oMenu, oBrush, oFont
     local l97Look  := oWndMain != nil .and. oWndMain:oBar != nil .and. ;
                       Len( oWndMain:oBar:aControls ) > 0 .and. ;
                       oWndMain:oBar:aControls[ 1 ]:l97Look
     LOCAL lExit := .F.
     local oHand

     #ifdef __CLIPPER__
        cResFile := "Preview.dll"
     #else
        cResFile := "Prev32.dll"
     #endif

     IF SetResources(cResFile) < 32
          MsgStop(cResFile + " not found, imposible to continue",;
                  "FiveWin Printing Error")
          RETU NIL
     ENDIF

     IF oWnd != NIL
          MsgStop(TXT_A_WINDOW_PREVIEW_IS_ALLREADY_RUNNING)
          SetResources(hOldRes)
          RETU NIL
     ENDIF

     if oWndMain != nil
        oIcon = oWndMain:oIcon
     endif

     IF oDevice:lPrvModal .and. oWndMain != NIL
          oWndMain:Hide()
     ELSE
          lExit := .T.
     ENDIF

     DEFINE FONT oFont NAME GetSysFont() SIZE 0,-12

     DEFINE CURSOR oCursor RESOURCE "Lupa"

     DEFINE WINDOW oWnd FROM 0, 0 TO 24, 80  ;
          TITLE oDevice:cDocument            ;
          MENU BuildMenu()                   ;
          COLOR CLR_BLACK,CLR_LIGHTGRAY      ;
          ICON  oIcon                        ;
          VSCROLL HSCROLL

     oWnd:SetFont(oFont)
     oWnd:oVScroll:SetRange(0,0)
     oWnd:oHScroll:SetRange(0,0)

     DEFINE CURSOR oHand HAND

     DEFINE BUTTONBAR oBar _3D SIZE 26, iif( LargeFonts(), 30, 26) OF oWnd

     oBar:bRClicked := {|| NIL }

     if l97Look
        DEFINE BUTTON RESOURCE "Top" OF oBar ;
             MESSAGE TXT_GOTO_FIRST_PAGE     ;
             ACTION TopPage()                ;
             TOOLTIP Strtran(TXT_FIRST,"&","") NOBORDER

        DEFINE BUTTON RESOURCE "Previous" OF oBar ;
             MESSAGE TXT_GOTO_PREVIOUS_PAGE       ;
             ACTION PrevPage()                    ;
             TOOLTIP Strtran(TXT_PREVIOUS,"&","") NOBORDER

        DEFINE BUTTON RESOURCE "Next" OF oBar ;
             MESSAGE TXT_GOTO_NEXT_PAGE       ;
             ACTION NextPage()                ;
             TOOLTIP Strtran(TXT_NEXT,"&","") NOBORDER

        DEFINE BUTTON RESOURCE "Bottom" OF oBar ;
             MESSAGE TXT_GOTO_LAST_PAGE         ;
             ACTION BottomPage()                ;
             TOOLTIP Strtran(TXT_LAST,"&","") NOBORDER

        DEFINE BUTTON oZoom RESOURCE "Zoom" OF oBar GROUP ;
             MESSAGE TXT_ZOOM_THE_PREVIEW                 ;
             ACTION Zoom()                                ;
             TOOLTIP Strtran(TXT_ZOOM,"&","") NOBORDER

        DEFINE BUTTON oTwoPages RESOURCE "Two_Pages" OF oBar  ;
             MESSAGE TXT_PREVIEW_ON_TWO_PAGES       ;
             ACTION TwoPages()                      ;
             TOOLTIP Strtran(TXT_TWOPAGES,"&","") NOBORDER

        DEFINE BUTTON RESOURCE "ACPMore" OF oBar GROUP ;
             MESSAGE TXT_ACPMORE                       ;
             ACTION  SetFactor( nil, +.05 )            ;
             TOOLTIP TXT_ACPMORE NOBORDER

        DEFINE BUTTON RESOURCE "ACPLess" OF oBar       ;
             MESSAGE TXT_ACPLESS                       ;
             ACTION  SetFactor( nil, -.05 )            ;
             TOOLTIP TXT_ACPLESS NOBORDER

        DEFINE BUTTON RESOURCE "ACPLeft" OF oBar GROUP ;
             MESSAGE TXT_ACPLEFT                       ;
             ACTION  Adjust( 1 )                       ;
             TOOLTIP TXT_ACPLEFT NOBORDER

        DEFINE BUTTON RESOURCE "ACPRight" OF oBar      ;
             MESSAGE TXT_ACPRIGHT                      ;
             ACTION  Adjust( 2 )                       ;
             TOOLTIP TXT_ACPRIGHT NOBORDER

        DEFINE BUTTON RESOURCE "ACPTop"   OF oBar      ;
             MESSAGE TXT_ACPTOP                        ;
             ACTION  Adjust( 3 )                       ;
             TOOLTIP TXT_ACPTOP NOBORDER

        DEFINE BUTTON RESOURCE "ACPBottom" OF oBar     ;
             MESSAGE TXT_ACPBOTTOM                     ;
             ACTION  Adjust( 4 )                       ;
             TOOLTIP TXT_ACPBOTTOM NOBORDER

        DEFINE BUTTON RESOURCE "Printer" OF oBar GROUP ;
             MESSAGE TXT_PRINT_CURRENT_PAGE            ;
             ACTION PrintPage()                        ;
             TOOLTIP Strtran(TXT_PRINT,"&","") NOBORDER

        DEFINE BUTTON RESOURCE "Exit" OF oBar GROUP ;
             MESSAGE TXT_EXIT_PREVIEW               ;
             ACTION oWnd:End()                      ;
             TOOLTIP Strtran(TXT_EXIT,"&","") NOBORDER

    else

        DEFINE BUTTON RESOURCE "Top" OF oBar ;
             MESSAGE TXT_GOTO_FIRST_PAGE     ;
             ACTION TopPage()                ;
             TOOLTIP Strtran(TXT_FIRST,"&","")

        DEFINE BUTTON RESOURCE "Previous" OF oBar ;
             MESSAGE TXT_GOTO_PREVIOUS_PAGE       ;
             ACTION PrevPage()                    ;
             TOOLTIP Strtran(TXT_PREVIOUS,"&","")

        DEFINE BUTTON RESOURCE "Next" OF oBar ;
             MESSAGE TXT_GOTO_NEXT_PAGE       ;
             ACTION NextPage()                ;
             TOOLTIP Strtran(TXT_NEXT,"&","")

        DEFINE BUTTON RESOURCE "Bottom" OF oBar ;
             MESSAGE TXT_GOTO_LAST_PAGE         ;
             ACTION BottomPage()                ;
             TOOLTIP Strtran(TXT_LAST,"&","")

        DEFINE BUTTON oZoom RESOURCE "Zoom" OF oBar GROUP ;
             MESSAGE TXT_ZOOM_THE_PREVIEW                 ;
             ACTION Zoom()                                ;
             TOOLTIP Strtran(TXT_ZOOM,"&","")

        DEFINE BUTTON oTwoPages RESOURCE "Two_Pages" OF oBar  ;
             MESSAGE TXT_PREVIEW_ON_TWO_PAGES       ;
             ACTION TwoPages()                      ;
             TOOLTIP Strtran(TXT_TWOPAGES,"&","")

        DEFINE BUTTON RESOURCE "ACPMore" OF oBar GROUP ;
             MESSAGE TXT_ACPMORE                       ;
             ACTION  SetFactor( nil, +.05 )            ;
             TOOLTIP TXT_ACPMORE

        DEFINE BUTTON RESOURCE "ACPLess" OF oBar       ;
             MESSAGE TXT_ACPLESS                       ;
             ACTION  SetFactor( nil, -.05 )            ;
             TOOLTIP TXT_ACPLESS

        DEFINE BUTTON RESOURCE "ACPLeft" OF oBar GROUP ;
             MESSAGE TXT_ACPLEFT                       ;
             ACTION  Adjust( 1 )                       ;
             TOOLTIP TXT_ACPLEFT

        DEFINE BUTTON RESOURCE "ACPRight" OF oBar      ;
             MESSAGE TXT_ACPRIGHT                      ;
             ACTION  Adjust( 2 )                       ;
             TOOLTIP TXT_ACPRIGHT

        DEFINE BUTTON RESOURCE "ACPTop"   OF oBar      ;
             MESSAGE TXT_ACPTOP                        ;
             ACTION  Adjust( 3 )                       ;
             TOOLTIP TXT_ACPTOP

        DEFINE BUTTON RESOURCE "ACPBottom" OF oBar     ;
             MESSAGE TXT_ACPBOTTOM                     ;
             ACTION  Adjust( 4 )                       ;
             TOOLTIP TXT_ACPBOTTOM

        DEFINE BUTTON RESOURCE "Printer" OF oBar GROUP ;
             MESSAGE TXT_PRINT_CURRENT_PAGE            ;
             ACTION PrintPage()                        ;
             TOOLTIP Strtran(TXT_PRINT,"&","")

        DEFINE BUTTON RESOURCE "Exit" OF oBar GROUP ;
             MESSAGE TXT_EXIT_PREVIEW               ;
             ACTION oWnd:End()                      ;
             TOOLTIP Strtran(TXT_EXIT,"&","")
     endif

     AEval( oBar:aControls, { | o | o:oCursor := oHand } )

     SET MESSAGE OF oWnd TO TXT_PREVIEW CENTERED ;
        NOINSET CLOCK DATE KEYBOARD

     oMeta1 := TMetaFile():New( 0, 0, 0, 0,;
                              aFiles[1],;
                              oWnd,;
                              CLR_BLACK,;
                              CLR_WHITE,;
                              oDevice:nHorzRes(),;
                              oDevice:nVertRes() )

     nXOrig = oMeta1:nXOrig
     nYOrig = oMeta1:nYOrig

     oMeta1:oCursor := oCursor
     oMeta1:blDblClick := { |nRow, nCol, nKeyFlags| ;
                            SetOrg1( nCol, nRow, nKeyFlags ) }

     oMeta1:bKeyDown := {|nKey,nFlags| CheckKey(nKey,nFlags)}

     #ifndef __XPP__ // XBPP bug. Warning: don't change this into #ifdef __CLIPPER__
         oMeta2 := TMetaFile():New( 0,0,0,0,"",;
                  oWnd,CLR_BLACK,CLR_WHITE,oDevice:nHorzRes(),;
                  oDevice:nVertRes())
     #else
         oMeta2 := TMetaFile():New():_New( 0,0,0,0,"",;
                  oWnd,CLR_BLACK,CLR_WHITE,oDevice:nHorzRes(),;
                  oDevice:nVertRes())
     #endif

     oMeta2:oCursor := oCursor
     oMeta2:blDblClick := {|nRow, nCol, nKeyFlags| ;
                           SetOrg2(nCol, nRow, nKeyFlags)}

     oMeta2:hide()

     nPage     := 1
     nZFactor  := 1
     lTwoPages := .F.
     lZoom     := .F.

     @ 7, 475 SAY oSay PROMPT "Factor:" ;
          SIZE 60, 15 PIXEL OF oBar FONT oFont

     @ 3, 525 COMBOBOX oFactor VAR nZFactor ;
          ITEMS {"1","2","3","4","5","6","7","8","9"} ;
          OF oBar FONT oFont PIXEL SIZE 35,200 ;
          ON CHANGE SetFactor(nZFactor)

     @ 7, 570 SAY oPAGE PROMPT TXT_PAGENUM+ltrim(str(nPage,4)) ;
          SIZE 180, 15 PIXEL OF oBar FONT oFont

     oFactor:Set3dLook()

     oWnd:cargo := oDevice

     WndCenter(oWnd:hWnd)

     SysRefresh()
     SetResources(hOldRes)

     oWnd:oHScroll:bPos := {|nPos| hScroll(GO_POS, .f., nPos)}
     oWnd:oVScroll:bPos := {|nPos| vScroll(GO_POS, .f., nPos)}

      // by Thefull( RafaCarmona ) -------------------------------------------
     oWnd:oHScroll:bTrack := {|nPos| oWnd:oHScroll:ThumbPos( nPos ) }
     oWnd:oVScroll:bTrack := {|nPos| oWnd:oVScroll:ThumbPos( nPos ) }

     SetFactor()

     ACTIVATE WINDOW   oWnd                      ;
          MAXIMIZED                              ;
          ON RESIZE    PaintMeta()               ;
          ON UP        vScroll(GO_UP)            ;
          ON DOWN      vScroll(GO_DOWN)          ;
          ON PAGEUP    vScroll(GO_UP,GO_PAGE)    ;
          ON PAGEDOWN  vScroll(GO_DOWN,GO_PAGE)  ;
          ON LEFT      hScroll(GO_LEFT)          ;
          ON RIGHT     hScroll(GO_RIGHT)         ;
          ON PAGELEFT  hScroll(GO_LEFT,GO_PAGE)  ;
          ON PAGERIGHT hScroll(GO_RIGHT,GO_PAGE) ;
          VALID        (oWnd:oIcon := NIL       ,;
                        oMeta1:End()            ,;
                        oMeta2:End()            ,;
                        oDevice:End()           ,;
                        oHand:End()             ,;
                        oWnd := NIL             ,;
                        lExit := .T.            ,;
                        .T.)

     DO WHILE !lExit
          SysWait(.1)
     ENDDO

     IF oDevice:lPrvModal  .and. oWndMain != NIL
          oWndMain:Show()
     ENDIF

Return (NIL)

//----------------------------------------------------------------------------//

STATIC FUNCTION BuildMenu()

     LOCAL nFor, oMenu

     aFactor := Array(9)

     MENU oMenu
          MENUITEM TXT_FILE
          MENU
               MENUITEM TXT_PRINT ACTION PrintPage() ;
                    MESSAGE TXT_PRINT_CURRENT_PAGE RESOURCE "Printer"

               SEPARATOR

               MENUITEM TXT_EXIT ACTION oWnd:End() ;
                    MESSAGE TXT_EXIT_PREVIEW RESOURCE "Exit"
          ENDMENU

          MENUITEM TXT_PAGE
          MENU
               MENUITEM TXT_FIRST ACTION TopPage() ;
                    MESSAGE TXT_GOTO_FIRST_PAGE RESOURCE "Top"

               MENUITEM TXT_PREVIOUS ACTION PrevPage() ;
                    MESSAGE TXT_GOTO_PREVIOUS_PAGE RESOURCE "Previous"

               MENUITEM TXT_NEXT ACTION NextPage() ;
                    MESSAGE TXT_GOTO_NEXT_PAGE RESOURCE "Next"

               MENUITEM TXT_LAST ACTION BottomPage() ;
                    MESSAGE TXT_GOTO_LAST_PAGE RESOURCE "Bottom"

               SEPARATOR

               MENUITEM  oMenuZoom PROMPT TXT_ZOOM ACTION Zoom(.T.) ;
                    ENABLED ;
                    MESSAGE TXT_ZOOM_THE_PREVIEW RESOURCE "Zoom"
               MENUITEM  oMenuUnZoom PROMPT TXT_UNZOOM ACTION Zoom(.T.) ;
                    DISABLED ;
                    MESSAGE TXT_UNZOOM_THE_PREVIEW RESOURCE "UnZoom"
               MENUITEM  "&Factor"  MESSAGE TXT_ZOOM_FACTOR
               MENU
               FOR nFor := 1 TO len(aFactor)

                    MENUITEM aFactor[nFor]                       ;
                         PROMPT "&"+ltrim(str(nFor))             ;
                         MESSAGE "Factor "+ltrim(str(nFor))      ;
                         ACTION  (oFactor:Set(oMenuItem:nHelpId),;
                                  oFactor:Change()               )

               NEXT
               ENDMENU
               SEPARATOR

               MENUITEM oMenuTwoPages PROMPT TXT_TWOPAGES ACTION TwoPages(.T.) ;
                    ENABLED ;
                    MESSAGE TXT_PREVIEW_ON_TWO_PAGES RESOURCE "Two_Pages"
               MENUITEM oMenuOnePage PROMPT TXT_ONEPAGE ACTION TwoPages(.T.) ;
                    DISABLED ;
                    MESSAGE TXT_PREVIEW_ON_ONE_PAGE RESOURCE "One_Page"
          ENDMENU
   ENDMENU

return oMenu

//----------------------------------------------------------------------------//

STATIC Function PaintMeta()

     LOCAL oCoors1, oCoors2
     LOCAL aFiles := DEVICE:aMeta
     LOCAL nWidth, nHeight, nFactor

     IF IsIconic(oWnd:hWnd)
          RETU NIL
     ENDIF

     DO CASE
     CASE !lTwoPages

          IF !lZoom

               IF DEVICE:nHorzSize() >= ;        // Apaisado
                  DEVICE:nVertSize()
                    nFactor := .4
               ELSE
                    nFactor := .25
               ENDIF

          ELSE
               nFactor := .47
          ENDIF

          nWidth  := oWnd:nRight-oWnd:nLeft+1 - iif(lZoom,20 ,0 )
          nHeight := oWnd:nBottom-oWnd:nTop+1 - iif(lZoom,20 ,0 )

          oCoors1 := TRect():New(50,;
                                nWidth/2-(nWidth*nFactor),;
                                nHeight-iif( largefonts(),100 , 80),;
                                nWidth/2+(nWidth*nFactor))


          oMeta2:Hide()
          oMeta1:SetCoors(oCoors1)

     CASE lTwoPages

          nFactor := .4
          aFiles  := DEVICE:aMeta

          nWidth  := oWnd:nRight-oWnd:nLeft+1
          nHeight := oWnd:nBottom-oWnd:nTop+1

          oCoors1 := TRect():New(50,;
                                (nWidth/4)-((nWidth/2)*nFactor),;
                                nHeight-iif( largefonts(),100 , 80),;
                                (nWidth/4)+((nWidth/2)*nFactor))
          oCoors2 := TRect():New(50,;
                                (nWidth/4)-((nWidth/2)*nFactor)+(nWidth/2),;
                                nHeight-iif( largefonts(),100 , 80),;
                                (nWidth/4)+((nWidth/2)*nFactor)+(nWidth/2))

          IF nPage == Len(aFiles)
               oMeta2:SetFile("")
          ELSE
               oMeta2:SetFile(aFiles[nPage+1])
          ENDIF

          oMeta1:SetCoors(oCoors1)
          oMeta2:SetCoors(oCoors2)
          oMeta2:Show()

     ENDCASE

     oMeta1:SetFocus()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC Function NextPage()

     LOCAL hOldRes := GetResources()
     LOCAL aFiles := DEVICE:aMeta

     IF nPage == len(aFiles)
          MessageBeep()
          RETU NIL
     ENDIF

     nPage++

     SET RESOURCES TO cResFile

     oMeta1:SetFile(aFiles[nPage])
     oPage:SetText(TXT_PAGENUM+ltrim(str(nPage,4,0))+" / "+ltrim(str(len(aFiles))))

     oMeta1:Refresh()

     IF lTwoPages
          IF len(aFiles) >= (nPage+1)
               oMeta2:SetFile(aFiles[nPage+1])
          ELSE
               oMeta2:SetFile("")
          ENDIF
          oMeta2:Refresh()
     ENDIF

     oMeta1:SetFocus()

     SetResources(hOldRes)

RETURN NIL

//----------------------------------------------------------------------------//

STATIC Function PrevPage()

     LOCAL hOldRes := GetResources()
     LOCAL aFiles := DEVICE:aMeta

     IF nPage == 1
          MessageBeep()
          RETU NIL
     ENDIF

     nPage--

     SET RESOURCES TO cResFile

     oMeta1:SetFile(aFiles[nPage])
     oPage:SetText(TXT_PAGENUM+ltrim(str(nPage,4,0))+" / "+ltrim(str(len(aFiles))))
     oMeta1:Refresh()

     IF lTwoPages
          IF len(aFiles) >= nPage+1
               oMeta2:SetFile(aFiles[nPage+1])
          ELSE
               oMeta2:SetFile("")
          ENDIF
          oMeta2:Refresh()
     ENDIF

     oMeta1:SetFocus()

     SetResources(hOldRes)

RETURN NIL

//----------------------------------------------------------------------------//

STATIC Function TopPage()

     LOCAL hOldRes := GetResources()
     LOCAL aFiles := DEVICE:aMeta

     IF nPage == 1
          MessageBeep()
          RETU NIL
     ENDIF

     nPage   := 1

     SET RESOURCES TO cResFile

     oMeta1:SetFile(aFiles[nPage])
     oPage:SetText(TXT_PAGENUM+ltrim(str(nPage,4,0))+" / "+ltrim(str(len(aFiles))))

     oMeta1:Refresh()

     IF lTwoPages
          IF len(aFiles) >= nPage+1
               oMeta2:SetFile(aFiles[nPage+1])
          ELSE
               oMeta2:SetFile("")
          ENDIF
          oMeta2:Refresh()
     ENDIF

     oMeta1:SetFocus()

     SetResources(hOldRes)

RETURN NIL

//----------------------------------------------------------------------------//

STATIC Function BottomPage()

     LOCAL hOldRes := GetResources()
     LOCAL aFiles := DEVICE:aMeta

     IF nPage == len(aFiles)
          MessageBeep()
          RETU NIL
     ENDIF

     nPage   := len(aFiles)

     SET RESOURCES TO cResFile

     oMeta1:SetFile(aFiles[nPage])
     oPage:SetText(TXT_PAGENUM+ltrim(str(nPage,4,0))+" / "+ltrim(str(len(aFiles))))

     oMeta1:Refresh()

     IF lTwoPages
          oMeta2:SetFile("")
          oMeta2:Refresh()
     ENDIF

     oMeta1:SetFocus()
     SetResources(hOldRes)

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION TwoPages(lMenu)

     LOCAL hOldRes := GetResources()

     SET RESOURCES TO cResFile

     DEFAULT lMenu := .F.

     lTwoPages := !lTwoPages

     IF lTwoPages

          IF len(DEVICE:aMeta) == 1 // solo hay una pagina
               lTwoPages := !lTwoPages
               MessageBeep()
               SetResources(hOldRes)
               RETU NIL
          ENDIF

          IF DEVICE:nHorzSize() >= ;        // Apaisado
             DEVICE:nVertSize()
               lTwoPages := !lTwoPages
               MessageBeep()
               SetResources(hOldRes)
               RETU NIL
          ENDIF

          IF lZoom
               Zoom(.T.)
          ENDIF

          oTwoPages:FreeBitmaps()
          oTwoPages:LoadBitmaps("One_Page")
          oTwoPages:cMsg := TXT_PREVIEW_ON_ONE_PAGE
          oTwoPages:cTooltip := StrTran(TXT_ONEPAGE,"&","")
          oMenuTwoPages:disable()
          oMenuOnePage:enable()

     ELSE

          oTwoPages:FreeBitmaps()
          oTwoPages:LoadBitmaps("Two_Pages")
          oTwoPages:cMsg     := TXT_PREVIEW_ON_TWO_PAGES
          oTwoPages:cTooltip := StrTran(TXT_TWOPAGES,"&","")
          oMenuTwoPages:enable()
          oMenuOnePage:disable()

     ENDIF

     IF lMenu
          oTwoPages:Refresh()
     ENDIF

     oWnd:Refresh()
     PaintMeta()
     SetResources(hOldRes)

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION Zoom(lMenu)

     LOCAL hOldRes := GetResources()

     SET RESOURCES TO cResFile

     DEFAULT lMenu := .F.

     lZoom := !lZoom

     IF lZoom

          IF lTwoPages
               TwoPages(.T.)
          ENDIF

          oZoom:FreeBitmaps()
          oZoom:LoadBitmaps("Unzoom")
          oZoom:cMsg := TXT_UNZOOM_THE_PREVIEW
          oZoom:cTooltip := StrTran(TXT_UNZOOM,"&","")
          oMenuZoom:disable()
          oMenuUnZoom:enable()

          oWnd:oVScroll:SetRange(1,VSCROLL_RANGE)
          oWnd:oHScroll:SetRange(1,HSCROLL_RANGE)

          oMeta1:ZoomIn()

     ELSE

          oZoom:FreeBitmaps()
          oZoom:LoadBitmaps("Zoom")
          oZoom:cMsg := TXT_ZOOM_THE_PREVIEW
          oZoom:cTooltip := StrTran(TXT_ZOOM,"&","")
          oMenuZoom:enable()
          oMenuUnZoom:disable()

          oWnd:oVScroll:SetRange(0,0)
          oWnd:oHScroll:SetRange(0,0)

          oMeta1:ZoomOut()

     ENDIF

     IF lMenu
          oZoom:Refresh()
     ENDIF

     PaintMeta()
     SetResources(hOldRes)

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION VScroll(nType,lPage, nSteps)

     LOCAL nYfactor, nYorig, nStep

     DEFAULT lPage := .F.

     nYfactor := Int(DEVICE:nVertRes()/oWnd:oVScroll:nMax)

     IF nSteps != NIL
          nStep := nSteps
     ELSEIF lPage
          nStep := oWnd:oVScroll:nMax/10
     ELSE
          nStep := 1
     ENDIF

     IF nType == GO_UP
          nStep := -(nStep)
     ELSEIF nType == GO_POS
          oWnd:oVscroll:SetPos(nSteps)
          nStep := 0
     ENDIF

     nYorig := nYfactor * (oWnd:oVScroll:GetPos() + nStep - 1)

     IF nYorig > DEVICE:nVertRes()
          nYorig := DEVICE:nVertRes()
     ENDIF

     IF nYorig < 0
          nYorig := 0
     ENDIF

     oMeta1:SetOrg(NIL,nYorig)

     oMeta1:Refresh()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION HScroll(nType,lPage, nSteps)

     LOCAL nXfactor, nXorig, nStep

     DEFAULT lPage := .F.

     nXfactor := Int(DEVICE:nHorzRes()/oWnd:oHScroll:nMax)

     IF nSteps != NIL
          nStep := nSteps
     ELSEIF lPage
          nStep := oWnd:oHScroll:nMax/10
     ELSE
          nStep := 1
     ENDIF

     IF nType == GO_LEFT
          nStep := -(nStep)
     ELSEIF nType == GO_POS
          oWnd:oHscroll:SetPos(nSteps)
          nStep := 0
     ENDIF

     nXorig := nXfactor * (oWnd:oHScroll:GetPos() + nStep - 1)

     IF nXorig > DEVICE:nHorzRes()
          nXorig := DEVICE:nHorzRes()
     ENDIF

     IF nXorig < 0
          nXorig := 0
     ENDIF

     oMeta1:SetOrg(nXorig,NIL)

     oMeta1:Refresh()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION SetOrg1(nX, nY)

     LOCAL oCoors
     LOCAL nXStep, nYStep, nXFactor, nYFactor,;
           nWidth, nHeight, nXOrg

     IF lZoom
          Zoom(.T.)
          RETU NIL
     ENDIF

     oCoors   := oMeta1:GetRect()
     nWidth   := oCoors:nRight - oCoors:nLeft + 1
     nHeight  := oCoors:nBottom - oCoors:nTop + 1
     nXStep   := Max(Int(nX/nWidth*HSCROLL_RANGE) - 9, 0)
     nYStep   := Max(Int(nY/nHeight*VSCROLL_RANGE) - 9, 0)
     nXFactor := Int(DEVICE:nHorzRes()/HSCROLL_RANGE)
     nYFactor := Int(DEVICE:nVertRes()/VSCROLL_RANGE)

     Zoom(.T.)

     IF !empty(nXStep)
          HScroll(2,,nxStep)
          oWnd:oHScroll:SetPos(nxStep)
     ENDIF

     IF !empty(nYStep)
          VScroll(2,,nyStep)
          oWnd:oVScroll:SetPos(nyStep)
     ENDIF

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION SetOrg2(nX, nY)

     LOCAL oCoors
     LOCAL aFiles
     LOCAL nXStep, nYStep, nXFactor, nYFactor,;
           nWidth, nHeight, nXOrg

     IF oMeta2:cCaption == ""
          RETU NIL
     ENDIF

     IF lZoom
          Zoom(.T.)
          RETU NIL
     ENDIF

     oCoors   := oMeta2:GetRect()
     nWidth   := oCoors:nRight - oCoors:nLeft + 1
     nHeight  := oCoors:nBottom - oCoors:nTop + 1
     nXStep   := Max(Int(nX/nWidth*HSCROLL_RANGE) - 9, 0)
     nYStep   := Max(Int(nY/nHeight*VSCROLL_RANGE) - 9, 0)
     nXFactor := Int(DEVICE:nHorzRes()/HSCROLL_RANGE)
     nYFactor := Int(DEVICE:nVertRes()/VSCROLL_RANGE)

     oMeta1:SetFile(oMeta2:cCaption)

     aFiles := DEVICE:aMeta

     IF nPage = len(aFiles)
          oMeta2:SetFile("")
     ELSE
          oMeta2:SetFile(aFiles[++nPage])
     ENDIF

     oPage:Refresh()

     Zoom(.T.)

     IF !empty(nXStep)
          HScroll(2,,nxStep)
          oWnd:oHScroll:SetPos(nxStep)
     ENDIF

     IF !empty(nYStep)
          VScroll(2,,nyStep)
          oWnd:oVScroll:SetPos(nyStep)
     ENDIF

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION CheckKey (nKey,nFlags) // Thanks to Joerg K.

   if GetKeyState( VK_CONTROL )

      do case

         case nKey == 37                   //Left
              Adjust( 1 )

         case nKey == 39                   //Right
              Adjust( 2 )

         case nKey == 38                   //Up
              Adjust( 3 )

         case nKey == 40                   //Down
              Adjust( 4 )

         case nKey == 80                   //P
              PrintPage()

         case nKey == 109 .or. nKey == 189 //-
              SetFactor( nil, -.05 )

         case nKey == 107 .or. nKey == 187 //+
              SetFactor( nil, +.05 )

      endcase

   else

     IF !lZoom
          DO CASE
             CASE nKey == VK_HOME
                  TopPage()
             CASE nKey == VK_END
                  BottomPage()
             CASE nKey == VK_PRIOR
                  PrevPage()
             CASE nKey == VK_NEXT
                  NextPage()
          ENDCASE
     ELSE
          DO CASE
             CASE nKey == VK_UP
                  oWnd:oVScroll:GoUp()
             CASE nKey == VK_PRIOR
                  oWnd:oVScroll:PageUp()
             CASE nKey == VK_DOWN
                  oWnd:oVScroll:GoDown()
             CASE nKey == VK_NEXT
                  oWnd:oVScroll:PageDown()
             CASE nKey == VK_LEFT
                  oWnd:oHScroll:GoUp()
             CASE nKey == VK_RIGHT
                  oWnd:oHScroll:GoDown()
             CASE nKey == VK_HOME
                  oWnd:oVScroll:GoTop()
                  oWnd:oHScroll:GoTop()
                  oMeta1:SetOrg(0,0)
                  oMeta1:Refresh()
             CASE nKey == VK_END
                  oWnd:oVScroll:GoBottom()
                  oWnd:oHScroll:GoBottom()
                  oMeta1:SetOrg(.8*DEVICE:nHorzRes(),.8*DEVICE:nVertRes())
                  oMeta1:Refresh()
          ENDCASE
     ENDIF

   endif

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION SetFactor( nValue, nFine )

     LOCAL lInit := .F.

     IF nValue == NIL .and. nFine == nil
          Aeval(aFactor, {|v,e| v:nHelpId := e})
          nValue := nZFactor
          lInit  := .T.
     ENDIF

     if nFine != nil
        nZFactor += nFine
     endif

     Aeval(aFactor, {|val,elem| val:SetCheck( (elem == nZFactor) ) })

     oMeta1:SetZoomFactor(nZFactor, nZFactor*2)

     IF !lZoom .AND. !lInit
          Zoom(.T.)
     ENDIF

     IF lZoom
          oWnd:oVScroll:SetRange(1,VSCROLL_RANGE)
          oWnd:oHScroll:SetRange(1,HSCROLL_RANGE)
     ENDIF

     oMeta1:SetFocus()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC Function PrintPage()

     LOCAL hOldRes := GetResources()
     LOCAL hMeta   := oMeta1:hMeta

     LOCAL oDlg, oRad, oPageIni, oPageFin

     LOCAL nOption := 1 ,;
           nFirst  := 1 ,;
           nLast   := len(DEVICE:aMeta)

     IF nLast == 1
          PrintPrv(NIL, nOption, nFirst, nLast)
          RETU NIL
     ENDIF

     SET RESOURCES TO cResFile

     DEFINE DIALOG oDlg RESOURCE "PRINT"

     REDEFINE BUTTON ID 101 OF oDlg ;
          ACTION PrintPrv(oDlg, nOption, nFirst, nLast)

     REDEFINE BUTTON ID 102 OF oDlg ACTION oDlg:End()

     REDEFINE RADIO oRad VAR nOption ID 103,104,105 OF oDlg ;
          ON CHANGE iif(nOption==3 ,;
                       (oPageIni:Enable(),oPageFin:Enable()) ,;
                       (oPageIni:Disable(),oPageFin:Disable()) )

     REDEFINE GET oPageIni ;
          VAR nFirst ;
          ID 106 ;
          PICTURE "@K 99999" ;
          VALID iif(nFirst<1 .OR. nFirst>nLast,(MessageBeep(),.F.),.T.) ;
          OF oDlg

     REDEFINE GET oPageFin ;
          VAR nLast ;
          ID 107 ;
          PICTURE "@K 99999" ;
          VALID iif(nLast<nFirst .OR. nLast>len(DEVICE:aMeta), ;
                    (MessageBeep(),.F.),.T.) ;
          OF oDlg

     oPageIni:Disable()
     oPageFin:Disable()

     SetResources(hOldRes )

     ACTIVATE DIALOG oDlg

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION PrintPrv(oDlg, nOption, nPageIni, nPageEnd)

     Local oDevice := DEVICE
     LOCAL aFiles := oDevice:aMeta
     LOCAL hMeta := oMeta1:hMeta
     LOCAL nFor

     CursorWait()

     StartDoc(oDevice:hDC, oDevice:cDocument )

     DO CASE

     CASE nOption == 1                           // All

          FOR nFor := 1 TO len(aFiles)
               StartPage(oDevice:hDC)
               hMeta := GetMetaFile(aFiles[nFor])
               PlayMetaFile( oDevice:hDC, hMeta )
               DeleteMetafile(hMeta)
               EndPage(oDevice:hDC)
          NEXT

     CASE nOption == 2                           // Current page

          StartPage(oDevice:hDC)
          hMeta := GetMetaFile(aFiles[nPage])
          PlayMetaFile( oDevice:hDC, hMeta )
          EndPage(oDevice:hDC)

     CASE nOption == 3                           // Range

          FOR nFor := nPageIni TO nPageEnd
               StartPage(oDevice:hDC)
               hMeta := GetMetaFile(aFiles[nFor])
               PlayMetaFile( oDevice:hDC, hMeta )
               DeleteMetafile(hMeta)
               EndPage(oDevice:hDC)
          NEXT

     ENDCASE

     EndDoc(oDevice:hDC)

     CursorArrow()

     IF oDlg != NIL
          oDlg:End()
     ENDIF

RETURN NIL

//----------------------------------------------------------------------------//

static procedure Adjust( nPos )

   if nPos == 1 .or. nPos == 2
      nXorig += If( nPos == 1, 1, -1 )
   else
      nYorig += If( nPos == 3, 1, -1 )
   endif

   oMeta1:nXorig = nXorig
   oMeta1:nYorig = nYorig

   oMeta1:Refresh()

   if lTwoPages

      oMeta2:nXorig = nXorig
      oMeta2:nYorig = nYorig

      oMeta2:Refresh()

   endif

   oMeta1:SetFocus()

return

//----------------------------------------------------------------------------//

static function GetSysFont()
return "Ms Sans Serif"

//----------------------------------------------------------------------------//

