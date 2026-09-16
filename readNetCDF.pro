;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; readNetCDF.pro - IDL procedure to read in NetCDF 4 files with limitations
;                  listed below. The data is read in a specific format to not
;                  lose the case of names, attributes or dimensions and that
;                  structure is defined in the structure section.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Version : 1.1.2 - Not compatible with version 1.0.0.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Limitations :
;   - Unsigned 64-bit numbers are unsupported.
;   - There may only be one unlimited dimension per variable.
;   - The unlimited dimension must be the outer most (slowest growing)
;     dimension. In IDL this means the right most array value.
;   - Structures and groups are not supported.
;   - Currently the "CHAR", "UBYTE", and "BYTE" types are all read the same
;     way into IDL - becoming a BYTE. This means if written out again they
;     will change to a netCDF BYTE type.
;   - Attributes of type "CHAR" will be converted to a STRING. This will 
;     affect when they are written out again.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Notes :
;   - Variables which conflict with keywords or start with a number will be
;     modified by starting with "_ImportedVariable_" in their structure name
;     though their actual name will be preserved.
;    
;   - Variables which have dashes ('-'), dots ('.') or spaces (' ') will have
;     them converted converted to underscores ('_').
;    
;   - To quicken data read or shorten output the /noAttributes keyword or the
;     /noDimensions keyword can be flagged though this will then not include
;     the attribute or dimension data. This is useful if they are not needed
;     and no data will be re-written.
;    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; "data" Structure :
;   Attributes - This may not exist if there are no global attributes. When it
;                does exist it is a structure with one element per attribute
;                with names mirroring the attribute name. Each element follows
;                the "Attribute" structure format below. These all represent
;                the netCDF global attributes.
;   Dimensions - This may not exist if there are no dimensions in the netCDF
;                file (only scalars or no variables are in the file). When it
;                does exist it represents all of the dimensions used in the
;                netCDF file (referenced by each variable). The order is 
;                important as the variable dimension index will reference this
;                array.
;   Variables  - This may not exist if there are no variables in the netCDF
;                file. When it does exist, it represents the attributes, data,
;                dimensions and name of each variable in a structure. The 
;                structure has one name/component (per TAG_NAMES) per variable
;                in the netCDF file. Each element name mirrors the variable
;                name. The structure of each element is shown under the
;                "Variable" structure below.
;                
; "Attribute" Structure :
;   ID    - A long representing the ID of the attribute in the netCDF file.
;           This may be omitted or set to -1 during write. It is only useful
;           for informational purposes and may change during write.
;   Name  - A string indicating the name of the attribute.
;   Value - A scalar or vector (single dimension array) of scalars. The type
;           must correspond to a valid type per the type requirements defined
;           later.
;
; "Dimension" Structure :
;   ID    - A long representing the ID of the dimension in the netCDF file.
;           This may be omitted or set to -1 during write. It is only useful
;           for informational purposes and may change during a write.
;   Name  - A string indicating the name of the dimension.
;   Size  - A long indicating the dimension. It is only possible for this to
;           be zero if the dimension is unlimited. Even if a dimension is
;           unlimited it represents the current dimension. This must never
;           be negative but is kept a long for compatibility with netCDF.
;   Unlimited - A byte with a non-zero value if the dimension is unlimited.
;           Note that care must be taken when writing to ensure only one
;           unlimited dimension per variable (there may be more per file)
;           and that it is the last (IDL right most) dimension.
;           
; "Variable" Structure :
;   Attributes - This is a structure representing the variable attributes and
;                is omitted if there are no attributes. This structure contains
;                an element for each attribute and the name mirrors that of
;                the attribute. Each follows the "Attribute" structure defined
;                above.
;   Data       - This is a scalar or array containing the variable's actual
;                data. It may be missing if there is no data even though the
;                variable is defined (this should only happen if there is an
;                unlimited dimension that is currently set to zero). The type
;                restrictions follow the requirements enumerated below.
;   DimensionIndex - Only present if the variable is not a scalar. This is
;                an array of longs which indicate the index into the
;                data.dimensions structure. So a value of [1L, 0L, 3L] would
;                indicate the variable uses the second, first and forth 
;                dimensions in the data.dimensions structure in order and the
;                forth dimension is the only one which is allowed to be
;                unlimited.
;   Dimensions - An array of "Dimension" structures which are the dimensions
;                of the variable. These should match a dimension in the
;                data.dimensions structure and the DimensionIndex array will
;                point to the match. It is provided purely for information.
;                During write this can be used to make writing easier and in
;                place of the DimensionIndex notation. This will not be
;                present if this variable is a scalar.
;   ID         - A long representing the ID of the variable in the netCDF file.
;                This may be omitted or set to -1 during write. It is provided
;                for information purposes and may change during write.
;   Name       - A string representing the name of the variable.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Type Requirements : This netCDF reader only supports the types shown below.
;    BYTE   - NetCDF data of type Unsigned Byte, Signed Byte or Character are
;             converted to this type. When writing them back they will be as
;             an unsigned byte.
;    DOUBLE - NetCDF Double type.
;    FLOAT  - NetCDF Float type.
;    INT    - NetCDF Short type.
;    LONG   - NetCDF Int type.
;    LONG64 - NetCDF Int64 type. Note that the netCDF UInt64 type is converted
;             to this type as well in order to preserve JAVA compatibility.
;    STRING - NetCDF String and Character Arrays are converted to this type
;             and are written back as strings (not character arrays).
;    UINT   - NetCDF UShort type.
;    ULONG  - NetCDF UInt type.
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Data Transformations :
;   - CHAR netCDF type data are converted to IDL BYTE. The type will be a
;     BYTE if written back out.
;   - CHAR netCDF type attributes are read in as IDL STRINGs. When writing
;     back out later they will become a string.
;   - UBYTE netCDF type is read in as an IDL BYTE. The unsignedness of the
;     data is lost.
;   - UINT64 netCDF type is converted to an IDL LONG64 type.
;     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Examples:
; 
;   readNetCDF, '/home/user/myFile.txt', data
;   readNetCDF, '/home/user/myFile.txt', data, /noAttributes
;   readNetCDF, '/home/user/myFile.txt', data, status, /noDimensions
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; History:
; 
;  Date       Name          Action
;  ---------  ------------  ----------------------------------------------
;  06 Jun 97  S. Rupert     Created.
;  09 Jun 97  S. Rupert     Fully tested.rest
;  10 Jun 97  S. Rupert     Modified keyword usage.
;  03 Feb 98  S. Rupert     Added additional error checking, and warning to
;                           output script.
;  17 Feb 98  S. Rupert     Corrected validation routine to handle instance
;                           of name strating with a number and containing a
;                           dash.
;  17 Mar 02  D. Morrison   Changed routine to return data into a structure.
;  16 Sep 14  S. L. England Updated to handle collision with 'NE'.
;  15 May 16  T. N. Fae     Rewrite to enhance performance, support NetCDF
;                           4, read attributes, and keep the information
;                           about unlimited dimensions for later use with
;                           write. Also hid functions that should not be
;                           called outside of this file.
;  14 Jun 16  T. N. Fae     Changed format & structure to ensure preserving
;                           name case. Note that the name may be different if
;                           the naming rules are violated (keyword collision,
;                           dots, spaces or dashes). This change will affect
;                           code which uses the attribute data in the past.
;  01 Jul 16  T. N. Fae     Fixed BUG: "CHAR" variables with more than one
;                           dimension did not read to STRING correctly.
;                            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Internal Functions & Procedures
FORWARD_FUNCTION readAttributesNetCDF
FORWARD_FUNCTION readDimensionsNetCDF
FORWARD_FUNCTION readVariablesNetCDF
FORWARD_FUNCTION validateNameNetCDF





PRO readNetCDF, inFile, data, status, noAttributes=noAttributes, noClear=noClear, noDimensions=noDimensions
  ; Compile Options
  COMPILE_OPT IDL2
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Procedure Description
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Reads the NetCDF file specified by the inFile (which must be the full path)
  ; and places it in the specified IDL data structure. The names of variables
  ; and attributes may be changed if there is a conflict with IDL. Complex data
  ; types and structures (like groups and so forth) are not supported. Strings,
  ; integers, unsigned integers, floats and doubles are supported.
  ;
  ; Global attributes will be placed in the <Data>.Attributes area.
  ;
  ; Variables will be placed under the <Data> area as <Data>.<Variable>. The
  ; variable attributes will be placed as <Data>.<Variable>.Attributes area.
  ;
  ; Note: If the noAttribute flag is set then no attributes will be read.
  ;       Similarly, if the noDimensions flag is set then no dimension
  ;       structures will be created (though the variables will still have
  ;       dimensions).
  ;
  ; Inputs : inFile        - Full path of the NetCDF file to be read.
  ;          data          - Structure to fill with NetCDF data.
  ;          status        - {Output} {Optional} See "Outputs" below.
  ;          /noAttributes - Keyword indicating skip reading attributes.
  ;          /noClear      - Do not clear <data> before filling it.
  ;          /noDimensions - Keyword indicating skip reading the dimensions
  ;                          (writing it out again will generate different
  ;                          dimensions so this may not be desirable).
  ; Outputs :
  ;  data   - Structure will be created in an expected format. See the data
  ;           structure definition above. 
  ;  status - {Optional} An integer indicates the status of the read.
  ;                0 = OK
  ;               -1 = BAD PARAMETERS (Input Parameters Unexpected)
  ;               -2 = BAD FILE (Unable to Open Specified File)
  ;               -3 = BAD FILE DATA (Unable to Read NetCDF File)
  ;               -5 = NOT SUPPORTED (NetCDF is Not Supported)
  ;
  ; Examples:
  ;   readNetCDF, '/home/user/myFile.txt', data
  ;   readNetCDF, '/home/user/myFile.txt', data, status, /noAttributes
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; Status Return Values
  STATUS_OK                  =  0
  STATUS_BAD_PARAMETERS      = -1
  STATUS_BAD_FILE            = -2
  STATUS_BAD_FILE_DATA       = -3
  STATUS_NOT_SUPPORTED       = -5
  status                     = STATUS_OK

  ; Clear Input Data
  IF (NOT KEYWORD_SET(noClear)) THEN DELVAR,data

  ; Ensure that the netCDF format is supported on the current platform.
  IF (NOT(NCDF_EXISTS())) THEN BEGIN
    MESSAGE,"ERROR: The Network Common Data Format (netCDF) is not supported on this platform.",/CONTINUE
    status = STATUS_NOT_SUPPORTED
    RETURN
  ENDIF

  ; Correct # of Parameters?
  IF (2 GT N_PARAMS()) THEN BEGIN
    MESSAGE,"Usage: readNetCDF, inFile, data, status, /noAttributes, /noDimensions"      +STRING(10B)+$
            STRING(9B)+"inFile        - Full path to NetCDF file to read."               +STRING(10B)+$
            STRING(9B)+"data          - Desired name of resultant IDL data structure."   +STRING(10B)+$
            STRING(9B)+"status        - {Optional} Status flag (0 indicates success)."   +STRING(10B)+$
            STRING(9B)+"/noAttributes - Keyword indicating removal of NetCDF attributes."+STRING(10B)+$
            STRING(9B)+"/noDimensions - Keyword indicating removal of NetCDF dimensions.",/CONTINUE
    status = STATUS_BAD_PARAMETERS
    RETURN
  ENDIF
  
  ; Open netCDF File
  inputFile = STRTRIM(inFile,2)
  IF (NOT FILE_TEST(inputFile,/READ)) THEN BEGIN
    MESSAGE,"ERROR: Unable to find file "+inputFile+" or it isn't readable.",/CONTINUE
    status = STATUS_BAD_FILE
    RETURN
  ENDIF
  ON_IOERROR,errorFile
  ncID = NCDF_OPEN(inputFile,/NOWRITE)
  IF (-1 EQ ncID) THEN GOTO,errorFile
  ncInformation = NCDF_INQUIRE(ncID)
  
  ; Read Dimensions
  dimensions = !NULL
  IF (NOT(KEYWORD_SET(noDimensions))) THEN status = readDimensionsNetCDF(ncID,dimensions)
  IF (STATUS_OK NE status) THEN GOTO,errorRead
  
  ; Load Global Attributes (Unless Not Requested)
  attributes = !NULL
  IF (NOT(KEYWORD_SET(noAttributes))) THEN status = readAttributesNetCDF(ncID,attributes)
  IF (STATUS_OK NE status) THEN GOTO,errorRead
  
  ; Read Variables
  variables = !NULL
  IF ( KEYWORD_SET(noAttributes) ) THEN status = readVariablesNetCDF(ncID,dimensions,variables,/noAttributes) $
  ELSE                                  status = readVariablesNetCDF(ncID,dimensions,variables              )
  
  ; Create Structure
  IF ( dimensions NE !NULL ) THEN BEGIN
    IF ( attributes NE !NULL ) THEN BEGIN
      IF ( variables NE !NULL ) THEN BEGIN
        data = CREATE_STRUCT( "Attributes", attributes , $
                              "Dimensions", dimensions , $
                              "Variables" , variables  )
      ENDIF ELSE BEGIN
        data = CREATE_STRUCT( "Attributes", attributes , $
                              "Dimensions", dimensions )
      ENDELSE
    ENDIF ELSE IF ( variables NE !NULL ) THEN BEGIN
        data = CREATE_STRUCT( "Dimensions", dimensions , $
                              "Variables" , variables  )
    ENDIF ELSE BEGIN
        data = CREATE_STRUCT( "Dimensions", dimensions )
    ENDELSE
  ENDIF ELSE IF ( attributes NE !NULL ) THEN BEGIN
    IF ( variables NE !NULL ) THEN BEGIN
        data = CREATE_STRUCT( "Attributes", attributes , $
                              "Variables" , variables  )
    ENDIF ELSE BEGIN
        data = CREATE_STRUCT( "Attributes", attributes )
    ENDELSE
  ENDIF ELSE IF ( variables NE !NULL ) THEN BEGIN
        data = CREATE_STRUCT( "Variables" , variables  )
  ENDIF
  
  ; Cleanup & Complete
  complete :
    DELVAR,attributes,dimensions,variables
    IF (!NULL NE ncID) THEN NCDF_CLOSE,ncID
    RETURN

  ; Error Accessing File
  errorFile :
    MESSAGE,"ERROR: Unable to read netCDF file '"+inputFile+"'.",/CONTINUE
    status = STATUS_BAD_FILE
    GOTO,complete
    
  ; Error Reading Data
  errorRead :
    MESSAGE,"ERROR: Error reading data from netCDF file '"+inputFile+"'.",/CONTINUE
    status = STATUS_BAD_FILE_DATA
    GOTO,complete
END




PRO createStructureNetCDF, data, typeString, dimensions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function Description
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Take a given type string from NetCDf and return a variable that has the
; same IDL type. Note: In the future this may size the structure as an array
; of the indicated dimensions but for now this seems unnecessary.
; 
; Inputs : data           - Parameter to fill with created structure.
;          typeString     - The type string information from a NetCDF
;                           inquery into the type of a NetCDF variable
;                           or attribute.
;          dimensions     - NetCDF dimension list for this data type.
;                           This may not be provided or be !NULL and 
;                           then is assumed for a single data point.
; Outputs: An IDL structure with correct type and dimensions in "data".
;
; Example:
;   TBD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Compile Flags
  COMPILE_OPT IDL2,HIDDEN
  
  ; Check Parameters
  IF ( 1 GT N_PARAMS() ) THEN BEGIN
    MESSAGE,"Called createStructureNetCDF with no parameters."
    data = !NULL
    RETURN
  ENDIF ELSE IF ( 2 GT N_PARAMS() ) THEN BEGIN
    ; No Type Given - Assume Single Float
    data = 0.0
    RETURN
  ENDIF

  ; Count Dimensions
  IF ( (2 EQ N_PARAMS())  OR  (!NULL EQ dimensions) ) THEN BEGIN
    ; No Dimensions, Assume Single
    dimensionCount  = 0
    dimensionString = ' '
  ENDIF ELSE BEGIN
    dimensionCount  = SIZE(dimensions,/N_ELEMENTS)
    dimensionOffset = 0
    
    ; Remove Inner Index for Character Strings
    IF ('CHAR' EQ STRUPCASE(typeString)) THEN BEGIN
      dimensionOffset = 1
      dimensionCount  = dimensionCount - 1
    ENDIF

    ; Create Dimension Index List String
    FOR index=0, dimensionCount-1 DO BEGIN
      IF ( 0 EQ index ) THEN BEGIN
        dimensionString = STRING(dimensions[index+dimensionOffset].SIZE)
      ENDIF ELSE BEGIN
        dimensionString = dimensionString+','+STRING(dimensions[index+dimensionOffset].SIZE)
      ENDELSE
    ENDFOR
  ENDELSE

  ; Dimension Error Checking
  IF ( dimensionCount GT 6 ) THEN BEGIN
    MESSAGE, "Variable contains more then 6 dimensions which is unsupported."
    data = !NULL
    RETURN
  ENDIF
  
  ; Convert Type
  SWITCH STRUPCASE(typeString) OF
    'BYTE' :
    'SBYTE':
    'UBYTE': BEGIN
      IF ( 0 EQ dimensionCount ) THEN BEGIN
        data = 0B
      ENDIF ELSE BEGIN
        success=EXECUTE('data=BYTARR('+dimensionString+')')
      ENDELSE
      BREAK
    END

    'CHAR'  :
    'STRING': BEGIN
      IF ( 0 EQ dimensionCount ) THEN BEGIN
        data = ' '
      ENDIF ELSE BEGIN
        success=EXECUTE('data=STRARR('+dimensionString+')')
      ENDELSE
      BREAK
    END

    'UINT'  :
    'USHORT': BEGIN
      IF ( 0 EQ dimensionCount ) THEN BEGIN
        data = 0US
      ENDIF ELSE BEGIN
        success=EXECUTE('data=UINTARR('+dimensionString+')')
      ENDELSE
      BREAK
    END

    'INT'  :
    'SHORT': BEGIN
        IF ( 0 EQ dimensionCount ) THEN BEGIN
          data = 0S
        ENDIF ELSE BEGIN
          success=EXECUTE('data=INTARR('+dimensionString+')')
        ENDELSE
        BREAK
      END

    'ULONG': BEGIN
      IF ( 0 EQ dimensionCount ) THEN BEGIN
        data = 0UL
      ENDIF ELSE BEGIN
        success=EXECUTE('data=ULONARR('+dimensionString+')')
      ENDELSE
      BREAK
    END

    'LONG': BEGIN
      IF ( 0 EQ dimensionCount ) THEN BEGIN
        data = 0L
      ENDIF ELSE BEGIN
        success=EXECUTE('data=LONARR('+dimensionString+')')
      ENDELSE
      BREAK
    END
    
    'UINT64'   :
    'ULONG64'  :
    'ULONGLONG': BEGIN
      IF ( 0 EQ dimensionCount ) THEN BEGIN
        data = 0ULL
      ENDIF ELSE BEGIN
        success=EXECUTE('data=ULON64ARR('+dimensionString+')')
      ENDELSE
      BREAK
    END

    'INT64'   :
    'LONG64'  :
    'LONGLONG': BEGIN
      IF ( 0 EQ dimensionCount ) THEN BEGIN
        data = 0LL
      ENDIF ELSE BEGIN
        success=EXECUTE('data=LON64ARR('+dimensionString+')')
      ENDELSE
      BREAK
    END
 
    'DOUBLE': BEGIN
      IF ( 0 EQ dimensionCount ) THEN BEGIN
        data = 0.0D
      ENDIF ELSE BEGIN
        success=EXECUTE('data=DBLARR('+dimensionString+')')
      ENDELSE
      BREAK
    END

    ; Default is FLOAT
    ELSE: BEGIN
      IF ( 0 EQ dimensionCount ) THEN BEGIN
        data = 0.0
      ENDIF ELSE BEGIN
        success=EXECUTE('data=FLTARR('+dimensionString+')')
      ENDELSE
      BREAK
    END
  ENDSWITCH

  ; Resulting Structure
  RETURN
END



FUNCTION readAttributesNetCDF, ncID, attributes, variableID
  ; Compile Options
  COMPILE_OPT IDL2,HIDDEN
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Function Description
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Return the attributes of an open netCDF file for the specified variable ID
  ; (as indicated from the indexing of NCDF_INQUIRE.NVARS). If no variable ID
  ; is specified then it is assumed that the GLOBAL attributes are requested.
  ;
  ; Attributes will be in a structure that contains name / value pairs where
  ; the names are a string and the values may be a scalar or one dimensional
  ; array of the supported types.
  ;
  ; NULL results when there are no attributes.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Inputs : ncID       - ID of netCDF returned by successful NCDF_OPEN.
  ;          attributes - Structure to fill with attributes.
  ;          variableID - Index of the netCDF variable (OPTIONAL) (will be
  ;                       GLOBAL attributes if not provided or NULL).
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Outputs : STATUS Integer
  ;              0 = OK
  ;             -1 = BAD PARAMETERS
  ;             -2 = BAD FILE
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Example :
  ;   status = readAttributesNetCDF,ncID,attributes
  ;   status = readAttributesNetCDF,ncID,attributes,variableID
  ;
  ; Sample Work Flow :
  ;   ncID          = NCDF_OPEN("/home/user/myFile.nc",/NOWRITE)
  ;   ncInformation = NCDF_INQUIRE(ncID)
  ;
  ;   ; Global Attributes
  ;   status = readAttributesNetCDF(ncID,attributes)
  ;   IF ( 0 NE status ) THEN GOTO,errorHandler
  ;
  ;   ; First Variable Attributes
  ;   IF ( ncInformation.NVARS NE 0 ) THEN BEGIN
  ;     status = readAttributesNetCDF(ncID,attributes,0) ;
  ;     IF ( 0 NE status ) THEN GOTO,errorHandler
  ;   ENDIF
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; Initialize Data
  attributes            = !NULL
  STATUS_OK             =  0
  STATUS_BAD_PARAMETERS = -1
  STATUS_BAD_FILE       = -2
  
  ; Check Global
  ON_IOERROR,errorFile
  IF (3 GT N_PARAMS()) THEN global = 1B ELSE global = 0B
  IF (global) THEN BEGIN
    ncInformation = NCDF_INQUIRE(ncID)
    count         = ncInformation.NGATTS
  ENDIF ELSE BEGIN
    ncInformation = NCDF_VARINQ(ncID,variableID)
    count         = ncInformation.NATTS
  ENDELSE
  
  ; No Data?
  IF (0 EQ count) THEN GOTO,complete
  
  ; Loop Attributes
  FOR index=0 , count-1 DO BEGIN
    ; Get Attribute Names
    IF (global) THEN nameNC = NCDF_ATTNAME(ncID,/GLOBAL   ,index) $
    ELSE             nameNC = NCDF_ATTNAME(ncID,variableID,index)
    name = validateNameNetCDF(nameNC)
    
    ; Get Type Information
    IF (global) THEN information = NCDF_ATTINQ(ncID,/GLOBAL   ,nameNC) $
    ELSE             information = NCDF_ATTINQ(ncID,variableID,nameNC)
    createStructureNetCDF,value,information.DataType
    typeString = SIZE(attributeValue,/TYPE) EQ 7
    
    ; Check String Conversion
    IF ( (typeString NE 0)  AND  (SIZE(value,/TYPE) NE 7) ) THEN value = STRING(value)
    
    ; Load Attribute
    IF (global) THEN NCDF_ATTGET,ncID,/GLOBAL   ,nameNC,value $
    ELSE             NCDF_ATTGET,ncID,variableID,nameNC,value
    
    ; Add to Structure
    attributes = CREATE_STRUCT(attributes,name,{ID:index,Name:name,Value:value})
  ENDFOR
  
  ; Success
  complete:
    ON_IOERROR,NULL
    RETURN,STATUS_OK
  
  ; File Error
  errorFile:
    MESSAGE,"ERROR: Unable to read attributes from netCDF file ID ["+STRTRIM(ncID,2)+"].",/CONTINUE
    ON_IOERROR,NULL
    RETURN,STATUS_BAD_FILE
END




FUNCTION readDimensionsNetCDF, ncID, dimensions
  ; Compile Options
  COMPILE_OPT IDL2,HIDDEN

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Function Description
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Return the dimensions of an open netCDF file using the netCDF file ID as
  ; an input. This will create an array of dimensions where each dimension
  ; follows the structure format:
  ;
  ;    DIMENSION.ID        = NetCDF File Dimension ID     (LONG) 
  ;    DIMENSION.name      = <Dimension Name>             (STRING)
  ;    DIMENSION.size      = <# of Elements in Dimension> (LONG)
  ;    DIMENSION.unlimited = <Non-ZERO if Unlimited>      (BYTE)
  ;
  ; Inputs : ncID - ID of netCDF returned by successful NCDF_OPEN
  ; Outputs: Dimension array (will be NULL if no dimensions)
  ;
  ; Example:
  ;   ncID       = NCDF_OPEN("/home/user/myFile.nc",/NOWRITE)
  ;   dimensions = readDimensionsNetCDF(ncID)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; The NC information structure from NCDF_INQUIRE should contain the number
  ; of dimensions in the netCDF file. If there are any then we read them and
  ; return the data otherwise we return empty data.
  ;
  ; NDIMS  = Dimension Count
  ; RECDIM = Set to -1 if no unlimited dimensions exist, otherwise set to an
  ;          index into the dimension array of the first UNLIMITED dimension.
  ;          Note: For ICON only 1 UNLIMITED dimension is supported on the
  ;                write side. They can be read otherwise.
  
  ; Initialize
  dimensions            = !NULL
  STATUS_OK             =  0
  STATUS_BAD_PARAMETERS = -1
  STATUS_BAD_FILE       = -2
  ON_IOERROR,errorFile
  
  ; Get Dimension Count
  ncInformation = NCDF_INQUIRE(ncID)
  IF ( ncInformation.NDIMS gt 0 ) THEN BEGIN
    ; Initialize data & type.
    dimensionID        = -1L
    dimensionName      = ' '
    dimensionSize      = 0L
    dimensionUnlimited = 0B
    dimension  = { Dimension, ID:dimensionID, name:dimensionName, size:dimensionSize, unlimited:dimensionUnlimited }
    dimensions = REPLICATE(dimension,ncInformation.NDIMS)
    
    ; Loop through each dimension.
    FOR index=0,ncInformation.NDIMS-1 DO BEGIN
      NCDF_DIMINQ,ncID,index,dimensionName,dimensionSize
      dimensions[index].ID   = index
      dimensions[index].name = dimensionName
      dimensions[index].size = dimensionSize
    ENDFOR
    
    ; Set unlimited dimension.
    IF (ncInformation.RECDIM NE -1) THEN dimensions[ncInformation.RECDIM].unlimited = 1B
  ENDIF
  
  ; Success
  ON_IOERROR,NULL
  RETURN,STATUS_OK
  
  ; Error Reading File
  errorFile :
    ON_IOERROR,NULL
    MESSAGE,"ERROR: Unable to read dimensions from netCDF file ID ["+STRTRIM(ncID,2)+"]."
    RETURN,STATUS_BAD_FILE
END




FUNCTION readVariablesNetCDF, ncID, dimensions, variables, noAttributes=noAttributes
  ; Compile Options
  COMPILE_OPT IDL2,HIDDEN
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Function Description
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; TBD
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; Initialize Data
  variables             = !NULL
  STATUS_OK             =  0
  STATUS_BAD_PARAMETERS = -1
  STATUS_BAD_FILE       = -2
  status                = STATUS_OK

  ; Invalid Entry?
  IF ( N_PARAMS() LT 3 ) THEN BEGIN
    MESSAGE,"Procedure readVariablesNetCDF expects 3 variables (ncID, dimensions, variables) and received less.",/CONTINUE
    RETURN,STATUS_BAD_PARAMETERS
  ENDIF
  
  ; Dimension Count
  dimensionCount = N_ELEMENTS(dimensions)
  
  ; Read Variable Count
  ON_IOERROR,errorFile
  ncInformation = NCDF_INQUIRE(ncID)
  IF ( ncInformation.NVARS EQ 0 ) THEN GOTO,complete
  
  ; Cycle Variable List
  FOR index=0, ncInformation.NVARS-1 DO BEGIN
    ; Get Variable Information
    variableInformation = NCDF_VARINQ(ncID,index)
    variableName        = validateNameNetCDF(variableInformation.name)
    variable            = {ID:index,Name:variableName}
    
    ; Dimension Error Checking
    variableDimensions = !NULL
    IF ( dimensions NE !NULL ) THEN BEGIN
      IF (variableInformation.NDIMS GT dimensionCount) THEN GOTO,errorDimensions
      
      ; Create Variable Dimensions
      IF ( 0 NE variableInformation.NDIMS) THEN BEGIN
        variableDimensions = [ dimensions[variableInformation.DIM[0]] ]
        FOR dimensionIndex=1, variableInformation.NDIMS-1 DO BEGIN
          variableDimensions = [ variableDimensions, dimensions[variableInformation.DIM[dimensionIndex]] ]
        ENDFOR
        variable = CREATE_STRUCT(variable,"DimensionIndex",variableInformation.DIM,"Dimensions",variableDimensions)
      ENDIF ELSE BEGIN
        variableDimensions = !NULL
      ENDELSE
    ENDIF ELSE IF ( 0 NE variableInformation.NDIMS ) THEN GOTO,errorDimensions
    
    ; Load Attributes
    IF ( (variableInformation.NATTS NE 0)  AND  NOT(KEYWORD_SET(noAttributes)) ) THEN BEGIN
      status = readAttributesNetCDF(ncID,attributes,index)
      IF (STATUS_OK NE status) THEN GOTO,complete
      variable = CREATE_STRUCT(variable,"Attributes",attributes)
    ENDIF
    
    ; Prepare Data Structure
    createStructureNetCDF,data,variableInformation.DATATYPE,variableDimensions
    NCDF_VARGET,ncID,index,data
    variable = CREATE_STRUCT(variable,"Data",data)
    DELVAR,data

    ; Append Variable Structure    
    variables = CREATE_STRUCT(variables,variableName,variable)
    DELVAR,variable
  ENDFOR
  
  ; Complete
  complete :
    ON_IOERROR,NULL
    RETURN,status
    
  ; Dimension Error
  errorDimensions :
    MESSAGE,variableName," contains more dimensions than are available.",/CONTINUE
    status = STATUS_BAD_FILE_DATA
    GOTO,complete

  ; File Access Error
  errorFile :
    status = STATUS_BAD_FILE
    MESSAGE,"ERROR: Unable to access or read from netCDF with file ID ["+STRTRIM(ncID,2)+"].",/CONTINUE
    GOTO,complete
END




FUNCTION validateNameNetCDF, incomingName
  ; Compile Options
  COMPILE_OPT IDL2,HIDDEN
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Function Description
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Ensure that the incoming name does not start with a number, contain a dash
  ; nor match a keyword from the dictionary (IDL will have problems with such
  ; names). Dashes ("-") and dots (".") are replaced with underscores ("_").
  ; Other issues with the name (starting with a number, being a keyword and so
  ; on) prepend the original name with "_IncomingVariable_".
  ;
  ; Note: This function could potentially be enhanced to handle variable name
  ;       collisions. For now a collision will overwrite a variable.
  ;
  ; Inputs : incomingName - Variable name to check.
  ; Outputs: Updated name (may be as original or modified as described).
  ;
  ; Example:
  ;   directory = getDir("/home/user/myFile.txt")
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; Check Parameters
  IF (0 EQ N_PARAMS()) THEN MESSAGE,"ERROR: Usage: newName = validateNameNetCDF(originalName)"
  name = SIZE(incomingName)
  IF (0 NE name[0])  OR  (7 NE name[1]) THEN MESSAGE,"ERROR: Inbound data was not a scalar string."
  
  ; Initialize Function
  name    = incomingName
  prepend = 0
  
  ; Replace "." & "-" with "_".
  IF (STRPOS(name,'-') NE -1) THEN BEGIN
    pieces = STR_SEP(name,'-')
    piecesCount = N_ELEMENTS(pieces)
    name = pieces(0)
    FOR index=1,piecesCount-1 DO BEGIN
      name = STRCOMPRESS(name+"_"+pieces(index))
    ENDFOR
  ENDIF
  IF (STRPOS(name,'.') NE -1) THEN BEGIN
    pieces = STR_SEP(name,'.')
    piecesCount = N_ELEMENTS(pieces)
    name = pieces(0)
    FOR index=1,piecesCount-1 DO BEGIN
      name = STRCOMPRESS(name+"_"+pieces(index))
    ENDFOR
  ENDIF
  
  ; Check Keyword Collision & Starting Number Issue
  IF (NOT(prepend)) THEN BEGIN
    checkName = IDL_VALIDNAME(name)
    IF STRLEN(checkName) LE 1 THEN prepend = 1
  ENDIF
  
  ; Check Unvalidated Reserved Words
  IF (NOT(prepend)) THEN BEGIN
    reservedWords = ['BREAK','CONTINUE','INHERITS']
    IF (!NULL NE WHERE(1 EQ STRCMP(name,reservedWords,/FOLD_CASE),/NULL)) THEN prepend = 1
  ENDIF
  
  ; Prepend Variable Tag if Problem Detected
  IF (prepend) THEN name = STRCOMPRESS("_IncomingVariable_"+name)
  
  ; Results
  RETURN,name
END
