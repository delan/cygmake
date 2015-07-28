!verbose push 
!verbose 3
!ifndef REQUIREVERSION_NSH
!define REQUIREVERSION_NSH

!macro REQUIRE_VERSION VER
!verbose push 
!verbose 3
!define /date WITHOUT_PREFIX %${NSIS_VERSION}
!if "${WITHOUT_PREFIX}" < "${VER}"
  !error "NSIS ${VER} or later required. You are using ${WITHOUT_PREFIX}."
!endif
!verbose pop
!macroend

!endif
!verbose pop
