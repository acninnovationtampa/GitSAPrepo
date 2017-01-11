* Konstanten für die Parameternamen der virtuellen Suchhilfe bei
* Festwerten
CONSTANTS: c_fval_low TYPE DFIES-FIELDNAME VALUE '_LOW',
           c_fval_high TYPE DFIES-FIELDNAME VALUE '_HIGH',
           c_fval_text TYPE DFIES-FIELDNAME VALUE '_TEXT',
           c_icon_fld TYPE DFIES-FIELDNAME VALUE '_ICON',
           c_pack_int TYPE SEAHLPRES-PACK_KIND VALUE 'I',
           c_pack_hist TYPE SEAHLPRES-PACK_KIND VALUE 'H',
           c_pack_pers TYPE SEAHLPRES-PACK_KIND VALUE 'P',
           c_mask_temp(1) TYPE C VALUE 'T'.

CLASS CL_ABAP_CHAR_UTILITIES DEFINITION LOAD.

DATA real_leng_for_makros TYPE I.

FIELD-SYMBOLS <record_mac> TYPE X.

DEFINE Assign_par.
* Mit diesem Makro wird ein Feldsymbol auf den Parameterinhalt in eine
* Zeile der Trefferliste gesetzt. Dabei ist &1 die Zeile der
* Trefferliste (also vom Typ SEAHLPRES), &2 die Beschreibung des
* Parameters (also vom Typ DFIES) und &3 ein untypisiertes Feldsymbol.
* &3 zeigt nachher auf den Inhalt des Parameters und hat dessen Typ (bei
* interner Darstellung, bzw. ist vom Typ C (bei externer Darstellung)
* mit der Ausgabelänge des Parameters als Länge.
       ASSIGN &1-STRING TO <record_mac> CASTING.
       IF &2-MASK+1(1) = 'E'.
          real_leng_for_makros
            = &2-OUTPUTLEN * CL_ABAP_CHAR_UTILITIES=>CHARSIZE.
          ASSIGN <record_mac>+&2-OFFSET(real_leng_for_makros) TO &3
                 TYPE 'C'.
       ELSEIF &2-INTTYPE = 'P'.
              ASSIGN <record_mac>+&2-OFFSET(&2-INTLEN) TO &3
                     TYPE 'P' DECIMALS &2-DECIMALS.
           ELSE.
                ASSIGN <record_mac>+&2-OFFSET(&2-INTLEN) TO &3
                       TYPE &2-INTTYPE.
       ENDIF.
END-OF-DEFINITION.                       " Assign_par
