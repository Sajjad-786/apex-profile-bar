prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2023.10.31'
,p_release=>'23.2.0'
,p_default_workspace_id=>62521001393553892
,p_default_application_id=>112
,p_default_id_offset=>0
,p_default_owner=>'CAMPUS_DEV'
);
end;
/
 
prompt APPLICATION 112 - 01. Weiße Elfen Campus Admin
--
-- Application Export:
--   Application:     112
--   Name:            01. Weiße Elfen Campus Admin
--   Date and Time:   22:47 Tuesday September 8, 2026
--   Exported By:     SAJJAD
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 111771349264624580
--   Manifest End
--   Version:         23.2.0
--   Instance ID:     709457783095702
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/region_type/profile_bar
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(111771349264624580)
,p_plugin_type=>'REGION TYPE'
,p_name=>'PROFILE_BAR'
,p_display_name=>'Profile Bar'
,p_javascript_file_urls=>'#PLUGIN_FILES#profile_bar#MIN#.js'
,p_css_file_urls=>'#PLUGIN_FILES#profile_bar#MIN#.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'------------------------------------------------------------------------',
'-- S&H Software Solutions - User Menu Region Plugin',
'-- ------------------------------------------------------------------',
'-- Component : Render Function ("PL/SQL Code" - Component Definition ->',
'--             Callbacks -> Render Function Type = PL/SQL Code)',
'-- Version   : 1.2.0 (NEW: Logout Style attribute (attribute_24) - four',
'--             static values STYLE1..STYLE4 controlling the visual',
'--             appearance of the OUTSIDE logout button only. CSS-only',
'--             variants, no JS changes required.)',
'-- Date      : 2026-09-04',
'-- Author    : S&H Software Solutions',
'-- License   : MIT License. This code is free and open to use, modify,',
'--             and redistribute, with or without attribution, for',
'--             personal or commercial projects.',
'-- ------------------------------------------------------------------',
'-- NOTE: attribute_20 (Width) and attribute_21 (Alignment) are no',
'-- longer read at all - safe to delete both from the plugin''s Custom',
'-- Attributes if you haven''t already.',
'------------------------------------------------------------------------',
'',
'FUNCTION render (',
'    p_region              IN apex_plugin.t_region,',
'    p_plugin              IN apex_plugin.t_plugin,',
'    p_is_printer_friendly IN BOOLEAN',
') RETURN apex_plugin.t_region_render_result',
'IS',
'    -- Above this size, a DB-driven profile image is skipped (falls',
'    -- back to initials) rather than being embedded as Base64.',
'    c_max_image_bytes CONSTANT INTEGER := 307200; -- 300 KB',
'',
'    ------------------------------------------------------------------',
'    -- Attribute values, read positionally',
'    ------------------------------------------------------------------',
'    v_show_image          VARCHAR2(4)    := p_region.attribute_01;',
'    v_image_source_attr   VARCHAR2(4000) := p_region.attribute_02;',
'    v_image_shape         VARCHAR2(20)   := NVL(p_region.attribute_03, ''ROUND'');',
'    v_image_size_attr     VARCHAR2(10)   := p_region.attribute_04;',
'    v_image_border_color  VARCHAR2(20)   := p_region.attribute_05;',
'    v_first_name_attr     VARCHAR2(2000) := p_region.attribute_06;',
'    v_email_attr          VARCHAR2(4000) := p_region.attribute_07;',
'    v_show_status          VARCHAR2(4)   := p_region.attribute_08;',
'    v_status_color_attr   VARCHAR2(20)   := p_region.attribute_09;',
'    v_show_logout         VARCHAR2(4)    := NVL(p_region.attribute_10, ''Y'');',
'    v_logout_link_attr    VARCHAR2(4000) := p_region.attribute_11;',
'    v_logout_icon_raw     VARCHAR2(200)  := NVL(p_region.attribute_12, ''fa-right-from-bracket'');',
'    v_logout_position     VARCHAR2(20)   := NVL(TRIM(p_region.attribute_13), ''OUTSIDE'');',
'    v_show_dropdown       VARCHAR2(4)    := NVL(p_region.attribute_14, ''Y'');',
'    v_dropdown_query      CLOB           := p_region.attribute_15;',
'    v_show_chevron        VARCHAR2(4)    := NVL(p_region.attribute_16, ''Y'');',
'    v_dropdown_bg_attr    VARCHAR2(20)   := p_region.attribute_17;',
'    v_dropdown_hover_attr VARCHAR2(20)   := p_region.attribute_18;',
'    v_dropdown_text_attr  VARCHAR2(20)   := p_region.attribute_19;',
'    -- attribute_20 (Width) and attribute_21 (Alignment) intentionally',
'    -- not read anymore - see header comment.',
'    v_last_name_attr      VARCHAR2(2000) := p_region.attribute_22;',
'    v_image_mime_attr     VARCHAR2(4000) := p_region.attribute_23;',
'    -- NEW: Logout Style - static LOV (STYLE1/STYLE2/STYLE3/STYLE4).',
'    -- Controls the OUTSIDE logout button''s visual variant via CSS',
'    -- class only; validated/defaulted in the executable section below.',
'    v_logout_style        VARCHAR2(20)   := NVL(UPPER(TRIM(p_region.attribute_24)), ''STYLE1'');',
'',
'    ------------------------------------------------------------------',
'    -- Resolved/derived values',
'    ------------------------------------------------------------------',
'    v_user_first_name VARCHAR2(4000);',
'    v_user_last_name  VARCHAR2(4000);',
'    v_user_name       VARCHAR2(4000);',
'    v_user_email      VARCHAR2(4000);',
'',
'    v_app_user VARCHAR2(4000);',
'',
'    v_email_is_db BOOLEAN;',
'    v_e_table VARCHAR2(128);',
'    v_e_match VARCHAR2(128);',
'    v_e_value VARCHAR2(128);',
'',
'    v_image_is_db    BOOLEAN;',
'    v_img_table      VARCHAR2(128);',
'    v_img_match      VARCHAR2(128);',
'    v_img_value      VARCHAR2(128);',
'    v_mime_table     VARCHAR2(128);',
'    v_mime_match     VARCHAR2(128);',
'    v_mime_value     VARCHAR2(128);',
'    v_image_blob     BLOB;',
'    v_image_mime     VARCHAR2(200);',
'    v_image_base64   CLOB;',
'    v_image_data_uri CLOB;',
'    v_image_src      VARCHAR2(4000);',
'',
'    v_static_id  VARCHAR2(200);',
'    v_wrapper_id VARCHAR2(200);',
'    v_panel_id   VARCHAR2(200);',
'',
'    v_html       CLOB;',
'    v_items_html CLOB;',
'',
'    -- Dropdown data, fetched positionally: icon / text / link / menu_type',
'    TYPE t_vc_tab IS TABLE OF VARCHAR2(4000);',
'    v_text_tab t_vc_tab := t_vc_tab();',
'    v_link_tab t_vc_tab := t_vc_tab();',
'    v_type_tab t_vc_tab := t_vc_tab();',
'    v_icons    t_vc_tab := t_vc_tab();',
'',
'    v_is_outside_logout BOOLEAN;',
'    v_is_inside_logout  BOOLEAN;',
'',
'    v_result apex_plugin.t_region_render_result;',
'',
'    ------------------------------------------------------------------',
'    -- Nested helpers - ALL after every variable above (PL/SQL rule: no',
'    -- variable declaration may follow a subprogram declaration in the',
'    -- same declare section).',
'    ------------------------------------------------------------------',
'',
'    FUNCTION f_number (',
'        pi_value   IN VARCHAR2,',
'        pi_default IN NUMBER',
'    ) RETURN NUMBER',
'    IS',
'        v_num NUMBER;',
'    BEGIN',
'        v_num := TO_NUMBER(pi_value);',
'        IF v_num IS NULL OR v_num <= 0 THEN',
'            RETURN pi_default;',
'        END IF;',
'        RETURN v_num;',
'    EXCEPTION',
'        WHEN OTHERS THEN',
'            RETURN pi_default;',
'    END f_number;',
'',
'    FUNCTION f_color (',
'        pi_color   IN VARCHAR2,',
'        pi_default IN VARCHAR2',
'    ) RETURN VARCHAR2',
'    IS',
'    BEGIN',
'        IF pi_color IS NOT NULL',
'           AND REGEXP_LIKE(pi_color, ''^#[0-9A-Fa-f]{3}([0-9A-Fa-f]{3})?$'')',
'        THEN',
'            RETURN pi_color;',
'        END IF;',
'        RETURN pi_default;',
'    END f_color;',
'',
'    FUNCTION f_icon_class (',
'        pi_icon IN VARCHAR2',
'    ) RETURN VARCHAR2',
'    IS',
'    BEGIN',
'        IF pi_icon IS NULL THEN',
'            RETURN NULL;',
'        END IF;',
'        IF pi_icon LIKE ''fa-%'' THEN',
'            RETURN ''fa '' || pi_icon;',
'        END IF;',
'        RETURN pi_icon;',
'    END f_icon_class;',
'',
'    FUNCTION f_initials (',
'        pi_name IN VARCHAR2',
'    ) RETURN VARCHAR2',
'    IS',
'        v_parts  apex_t_varchar2;',
'        v_result VARCHAR2(10) := '''';',
'    BEGIN',
'        IF pi_name IS NULL OR TRIM(pi_name) IS NULL THEN',
'            RETURN ''?'';',
'        END IF;',
'',
'        v_parts := apex_string.split(TRIM(pi_name), '' '');',
'',
'        FOR i IN 1 .. LEAST(v_parts.COUNT, 2) LOOP',
'            IF LENGTH(v_parts(i)) > 0 THEN',
'                v_result := v_result || UPPER(SUBSTR(v_parts(i), 1, 1));',
'            END IF;',
'        END LOOP;',
'',
'        RETURN NVL(NULLIF(v_result, ''''), ''?'');',
'    END f_initials;',
'',
'    ------------------------------------------------------------------',
'    -- Detects a "TABLE.MATCH_COLUMN.VALUE_COLUMN" reference (e.g.',
'    -- "SUPER_ADMIN.SUAD_EMAIL.SUAD_FIRST_NAME"). Returns TRUE and sets',
'    -- the OUT params when it matches; FALSE for anything else, so',
'    -- callers fall back to legacy literal-text behavior.',
'    ------------------------------------------------------------------',
'    FUNCTION f_parse_table_match_value (',
'        pi_ref    IN  VARCHAR2,',
'        po_table  OUT VARCHAR2,',
'        po_match  OUT VARCHAR2,',
'        po_value  OUT VARCHAR2',
'    ) RETURN BOOLEAN',
'    IS',
'        v_parts apex_t_varchar2;',
'    BEGIN',
'        po_table := NULL;',
'        po_match := NULL;',
'        po_value := NULL;',
'',
'        IF pi_ref IS NULL THEN',
'            RETURN FALSE;',
'        END IF;',
'',
'        IF REGEXP_LIKE(',
'               pi_ref,',
'               ''^[A-Za-z_][A-Za-z0-9_$#]*\.[A-Za-z_][A-Za-z0-9_$#]*\.[A-Za-z_][A-Za-z0-9_$#]*$''',
'           )',
'        THEN',
'            v_parts  := apex_string.split(pi_ref, ''.'');',
'            po_table := UPPER(v_parts(1));',
'            po_match := UPPER(v_parts(2));',
'            po_value := UPPER(v_parts(3));',
'            RETURN TRUE;',
'        END IF;',
'',
'        RETURN FALSE;',
'    END f_parse_table_match_value;',
'',
'    FUNCTION f_lookup_value (',
'        pi_table    IN VARCHAR2,',
'        pi_match    IN VARCHAR2,',
'        pi_value    IN VARCHAR2,',
'        pi_app_user IN VARCHAR2',
'    ) RETURN VARCHAR2',
'    IS',
'        v_result VARCHAR2(4000);',
'        v_sql    VARCHAR2(4000);',
'    BEGIN',
'        v_sql := ''SELECT '' || pi_value ||',
'                 '' FROM ''  || pi_table ||',
'                 '' WHERE UPPER('' || pi_match || '') = UPPER(:b1)'';',
'',
'        BEGIN',
'            EXECUTE IMMEDIATE v_sql INTO v_result USING pi_app_user;',
'        EXCEPTION',
'            WHEN NO_DATA_FOUND THEN',
'                v_result := NULL;',
'            WHEN OTHERS THEN',
'                apex_debug.error(',
'                    p_message => ''SH_USER_MENU: F_LOOKUP_VALUE lookup failed for %s.%s - %s'',',
'                    p0        => pi_table,',
'                    p1        => pi_value,',
'                    p2        => SQLERRM',
'                );',
'                v_result := NULL;',
'        END;',
'',
'        RETURN v_result;',
'    END f_lookup_value;',
'',
'    FUNCTION f_lookup_blob (',
'        pi_table    IN VARCHAR2,',
'        pi_match    IN VARCHAR2,',
'        pi_value    IN VARCHAR2,',
'        pi_app_user IN VARCHAR2',
'    ) RETURN BLOB',
'    IS',
'        v_result BLOB;',
'        v_sql    VARCHAR2(4000);',
'    BEGIN',
'        v_sql := ''SELECT '' || pi_value ||',
'                 '' FROM ''  || pi_table ||',
'                 '' WHERE UPPER('' || pi_match || '') = UPPER(:b1)'';',
'',
'        BEGIN',
'            EXECUTE IMMEDIATE v_sql INTO v_result USING pi_app_user;',
'        EXCEPTION',
'            WHEN NO_DATA_FOUND THEN',
'                v_result := NULL;',
'            WHEN OTHERS THEN',
'                apex_debug.error(',
'                    p_message => ''SH_USER_MENU: F_LOOKUP_BLOB lookup failed for %s.%s - %s'',',
'                    p0        => pi_table,',
'                    p1        => pi_value,',
'                    p2        => SQLERRM',
'                );',
'                v_result := NULL;',
'        END;',
'',
'        RETURN v_result;',
'    END f_lookup_blob;',
'',
'    ------------------------------------------------------------------',
'    -- Resolves a DB-driven text attribute (First Name / Last Name). If',
'    -- pi_attr is TABLE.MATCH.VALUE, runs the lookup; otherwise returns',
'    -- pi_attr unchanged (legacy literal text / &ITEM. string).',
'    ------------------------------------------------------------------',
'    FUNCTION f_resolve_text (',
'        pi_attr     IN VARCHAR2,',
'        pi_app_user IN VARCHAR2',
'    ) RETURN VARCHAR2',
'    IS',
'        v_table VARCHAR2(128);',
'        v_match VARCHAR2(128);',
'        v_value VARCHAR2(128);',
'    BEGIN',
'        IF f_parse_table_match_value(pi_attr, v_table, v_match, v_value) THEN',
'            RETURN f_lookup_value(v_table, v_match, v_value, pi_app_user);',
'        END IF;',
'        RETURN pi_attr;',
'    END f_resolve_text;',
'',
'    ------------------------------------------------------------------',
'    -- Splits an icon value on "|" into the icon itself and an optional',
'    -- hex color: "fa-star|#F59E0B" -> po_value=''fa-star'',',
'    -- po_color=''#F59E0B". No "|" present -> po_value=pi_raw, po_color',
'    -- stays NULL (inherits the default color from CSS). An invalid',
'    -- color after "|" is silently dropped (f_color validates it) -',
'    -- falls back to inherited color, no error, no broken markup.',
'    ------------------------------------------------------------------',
'    PROCEDURE p_parse_icon (',
'        pi_raw   IN  VARCHAR2,',
'        po_value OUT VARCHAR2,',
'        po_color OUT VARCHAR2',
'    )',
'    IS',
'        v_sep_pos PLS_INTEGER;',
'    BEGIN',
'        po_value := pi_raw;',
'        po_color := NULL;',
'',
'        IF pi_raw IS NULL THEN',
'            RETURN;',
'        END IF;',
'',
'        v_sep_pos := INSTR(pi_raw, ''|'');',
'        IF v_sep_pos > 0 THEN',
'            po_value := SUBSTR(pi_raw, 1, v_sep_pos - 1);',
'            po_color := f_color(SUBSTR(pi_raw, v_sep_pos + 1), NULL);',
'        END IF;',
'    END p_parse_icon;',
'',
'    ------------------------------------------------------------------',
'    -- Renders ONE icon''s markup - shared by the dropdown item loop AND',
'    -- the Logout icon (inside or outside), so both accept the same',
'    -- "icon_value" / "icon_value|#hexcolor" convention. Branches on',
'    -- whether the icon part looks like a Font Awesome shorthand',
unistr('    -- ("fa-...") or is plain text/emoji ("\D83D\DCAC", "\20AC", a single letter) -'),
'    -- the latter is rendered as literal text content instead of an',
'    -- icon-font CSS class, since a random emoji obviously isn''t a',
'    -- valid class name.',
'    ------------------------------------------------------------------',
'    FUNCTION f_render_icon_span (',
'        pi_raw IN VARCHAR2',
'    ) RETURN VARCHAR2',
'    IS',
'        v_value VARCHAR2(200);',
'        v_color VARCHAR2(20);',
'        v_style VARCHAR2(100);',
'    BEGIN',
'        p_parse_icon(pi_raw, v_value, v_color);',
'',
'        IF v_value IS NULL THEN',
'            RETURN NULL;',
'        END IF;',
'',
'        IF v_color IS NOT NULL THEN',
'            v_style := '' style="color:'' || v_color || ''"'';',
'        END IF;',
'',
'        IF v_value LIKE ''fa-%'' THEN',
'            RETURN ''<span class="'' ||',
'                apex_escape.html_attribute(f_icon_class(v_value)) || ''"'' ||',
'                v_style || '' aria-hidden="true"></span>'';',
'        END IF;',
'',
'        RETURN ''<span class="sh-um-item-icon-text"'' || v_style ||',
'            '' aria-hidden="true">'' || apex_escape.html(v_value) || ''</span>'';',
'    END f_render_icon_span;',
'',
'    ------------------------------------------------------------------',
'    -- Bilingual DE/EN text, mirroring the same txt() convention used',
'    -- client-side in the other S&H plugins (there: navigator.language;',
'    -- here: V(''BROWSER_LANGUAGE''), APEX''s server-side equivalent of the',
'    -- browser''s Accept-Language header). Used for the plugin''s own',
'    -- fixed UI strings ("Sign Out", the trigger''s aria-label) - NOT for',
'    -- developer-supplied content like dropdown item text, which stays',
'    -- exactly as configured.',
'    ------------------------------------------------------------------',
'    FUNCTION f_txt (',
'        pi_de IN VARCHAR2,',
'        pi_en IN VARCHAR2',
'    ) RETURN VARCHAR2',
'    IS',
'    BEGIN',
'        IF NVL(V(''BROWSER_LANGUAGE''), ''en'') LIKE ''de%'' THEN',
'            RETURN pi_de;',
'        END IF;',
'        RETURN pi_en;',
'    END f_txt;',
'',
'    ------------------------------------------------------------------',
'    -- Prints a CLOB via htp.prn in safely-sized chunks. htp.p/htp.prn',
'    -- only accept VARCHAR2, capped at 32767 BYTES (not characters).',
'    -- 8000 characters * up to 4 bytes/char (AL32UTF8 worst case) stays',
'    -- safely under that byte ceiling regardless of how many',
'    -- multi-byte characters land in any given chunk.',
'    ------------------------------------------------------------------',
'    PROCEDURE p_print_clob (',
'        pi_clob IN CLOB',
'    )',
'    IS',
'        v_len INTEGER;',
'        v_pos INTEGER := 1;',
'        v_amt CONSTANT PLS_INTEGER := 8000;',
'    BEGIN',
'        IF pi_clob IS NULL THEN',
'            RETURN;',
'        END IF;',
'',
'        v_len := DBMS_LOB.GETLENGTH(pi_clob);',
'',
'        WHILE v_pos <= v_len LOOP',
'            htp.prn(DBMS_LOB.SUBSTR(pi_clob, v_amt, v_pos));',
'            v_pos := v_pos + v_amt;',
'        END LOOP;',
'    END p_print_clob;',
'BEGIN',
'    v_app_user := V(''APP_USER'');',
'',
'    -- NEW: Logout Style must be one of the 4 static LOV values coming',
'    -- from attribute_24, else silently fall back to STYLE1 (defensive',
'    -- against blank/garbage values, same pattern as other attributes).',
'    IF v_logout_style NOT IN (''STYLE1'', ''STYLE2'', ''STYLE3'', ''STYLE4'') THEN',
'        v_logout_style := ''STYLE1'';',
'    END IF;',
'',
'    ----------------------------------------------------------------',
'    -- Resolve First Name / Last Name / Email. Each attribute is',
'    -- resolved independently - if written as e.g.',
'    -- "SUPER_ADMIN.SUAD_EMAIL.SUAD_FIRST_NAME" it runs its own lookup',
'    -- against that table, matched by SUAD_EMAIL against the current',
'    -- APP_USER. Anything NOT in that format is used as-is (legacy',
'    -- literal text / &ITEM. substitution string).',
'    --',
'    -- Email additionally falls back to APP_USER itself when it''s a DB',
'    -- lookup that finds no row - a deliberately blank literal Email',
'    -- attribute still renders blank either way.',
'    ----------------------------------------------------------------',
'    v_email_is_db := f_parse_table_match_value(v_email_attr, v_e_table, v_e_match, v_e_value);',
'',
'    IF v_email_is_db THEN',
'        v_user_email := f_lookup_value(v_e_table, v_e_match, v_e_value, v_app_user);',
'        IF v_user_email IS NULL THEN',
'            v_user_email := v_app_user;',
'        END IF;',
'    ELSE',
'        v_user_email := v_email_attr;',
'    END IF;',
'',
'    v_user_first_name := f_resolve_text(v_first_name_attr, v_app_user);',
'    v_user_last_name  := f_resolve_text(v_last_name_attr, v_app_user);',
'',
'    v_user_name := TRIM(NVL(v_user_first_name, '''') || '' '' || NVL(v_user_last_name, ''''));',
'',
'    ----------------------------------------------------------------',
'    -- Resolve the profile image. Image Source and Image Mime Type',
'    -- each carry their OWN table/match column:',
'    --   Image Source     -> SUPER_ADMIN.SUAD_EMAIL.SUAD_PROFILE_BLOB',
'    --   Image Mime Type  -> SUPER_ADMIN.SUAD_EMAIL.SUAD_PROFILE_MIME',
'    --',
'    -- If Image Source does NOT match that format, it''s used as a',
'    -- literal image URL (legacy behavior). If it DOES match, the BLOB',
'    -- is Base64-encoded via the built-in',
'    -- APEX_WEB_SERVICE.BLOB2CLOBBASE64 and embedded as a "data:" URI.',
'    -- Above c_max_image_bytes, it falls back to initials instead.',
'    ----------------------------------------------------------------',
'    v_image_is_db := f_parse_table_match_value(v_image_source_attr, v_img_table, v_img_match, v_img_value);',
'',
'    IF v_image_is_db THEN',
'        v_image_blob := f_lookup_blob(v_img_table, v_img_match, v_img_value, v_app_user);',
'',
'        IF v_image_blob IS NOT NULL AND DBMS_LOB.GETLENGTH(v_image_blob) > 0 THEN',
'            IF DBMS_LOB.GETLENGTH(v_image_blob) > c_max_image_bytes THEN',
'                apex_debug.warn(',
'                    p_message => ''SH_USER_MENU: profile image for %s is %s bytes (max %s) - falling back to initials.'',',
'                    p0        => v_img_table,',
'                    p1        => TO_CHAR(DBMS_LOB.GETLENGTH(v_image_blob)),',
'                    p2        => TO_CHAR(c_max_image_bytes)',
'                );',
'            ELSE',
'                IF f_parse_table_match_value(v_image_mime_attr, v_mime_table, v_mime_match, v_mime_value) THEN',
'                    v_image_mime := f_lookup_value(v_mime_table, v_mime_match, v_mime_value, v_app_user);',
'                END IF;',
'',
'                IF v_image_mime IS NULL THEN',
'                    apex_debug.warn(',
'                        p_message => ''SH_USER_MENU: no Image Mime Type resolved for %s - defaulting to image/png'',',
'                        p0        => v_img_table',
'                    );',
'                    v_image_mime := ''image/png'';',
'                END IF;',
'',
'                v_image_base64 := APEX_WEB_SERVICE.BLOB2CLOBBASE64(p_blob => v_image_blob);',
'',
'                -- MIME type is small (single DB column, not user',
'                -- input) - safe and cheap to escape normally. The',
'                -- Base64 payload is NOT escaped: apex_escape.html_attribute',
'                -- only accepts VARCHAR2 (32767-char ceiling) and a real',
'                -- photo easily encodes past that - escaping would be a',
'                -- no-op anyway, since Base64 never contains & < > " ''.',
'                v_image_data_uri := ''data:'' || apex_escape.html_attribute(v_image_mime) ||',
'                    '';base64,'' || v_image_base64;',
'            END IF;',
'        END IF;',
'    ELSE',
'        -- Legacy mode: literal URL / &ITEM. substitution string.',
'        v_image_src := v_image_source_attr;',
'    END IF;',
'',
'    ----------------------------------------------------------------',
'    -- Determine unique DOM ids for this region instance',
'    ----------------------------------------------------------------',
'    v_static_id  := NVL(p_region.static_id, ''r'' || p_region.id);',
'    v_wrapper_id := ''sh-um-'' || v_static_id;',
'    v_panel_id   := ''sh-um-panel-'' || v_static_id;',
'',
'    v_is_outside_logout := (v_show_logout = ''Y'' AND v_logout_position = ''OUTSIDE'');',
'    v_is_inside_logout  := (v_show_logout = ''Y'' AND v_logout_position = ''INSIDE'');',
'',
'    -- If no Logout Target is configured, fall back to APEX''s own',
'    -- built-in "LOGOUT" special request, which ends the session and',
'    -- redirects to the login page regardless of app-specific setup.',
'    IF v_logout_link_attr IS NULL THEN',
'        v_logout_link_attr := apex_page.get_url(p_request => ''LOGOUT'');',
'    END IF;',
'',
'    ----------------------------------------------------------------',
'    -- Load dropdown entries from the developer-supplied SQL query. If',
'    -- none is supplied, fall back to the plugin''s built-in default',
'    -- menu. Expected result: 4 columns in this order (icon, text,',
'    -- link, menu_type) - icon accepts "icon_value" or',
'    -- "icon_value|#hexcolor", see f_render_icon_span above. Wrapped in',
'    -- its own block so a broken query never breaks the page.',
'    ----------------------------------------------------------------',
'    IF v_show_dropdown = ''Y'' THEN',
'        IF v_dropdown_query IS NULL THEN',
'            v_dropdown_query :=',
'                q''[SELECT ''fa-gear''                          AS icon,',
'                          ''Settings''                         AS dropdown_text,',
'                          ''f?p=&APP_ID.:900:&SESSION.::::''   AS link,',
'                          ''MAIN''                             AS menu_type',
'                   FROM dual',
'                   UNION ALL',
'                   SELECT ''fa-user-circle'',',
'                          ''Campus Administrator'',',
'                          ''f?p=&APP_ID.:20:&SESSION.::::'',',
'                          ''MAIN''',
'                   FROM dual]'';',
'        END IF;',
'',
'        BEGIN',
'            EXECUTE IMMEDIATE v_dropdown_query',
'                BULK COLLECT INTO v_icons, v_text_tab, v_link_tab, v_type_tab;',
'        EXCEPTION',
'            WHEN OTHERS THEN',
'                apex_debug.error(',
'                    p_message => ''SH_USER_MENU: dropdown query failed - %s'',',
'                    p0        => SQLERRM',
'                );',
'                v_icons    := t_vc_tab();',
'                v_text_tab := t_vc_tab();',
'                v_link_tab := t_vc_tab();',
'                v_type_tab := t_vc_tab();',
'        END;',
'    END IF;',
'',
'    ----------------------------------------------------------------',
'    -- Build dropdown item rows',
'    ----------------------------------------------------------------',
'    v_items_html := '''';',
'',
'    FOR i IN 1 .. v_icons.COUNT LOOP',
'        v_items_html := v_items_html ||',
'            ''<div class="sh-um-item'' ||',
'            CASE WHEN UPPER(v_type_tab(i)) = ''SUB'' THEN '' sh-um-item--sub'' ELSE NULL END ||',
'            ''" data-link="'' || apex_escape.html_attribute(',
'                apex_util.prepare_url(p_url => v_link_tab(i))',
'            ) || ''" '' ||',
'            ''role="menuitem" tabindex="-1">'' ||',
'            ''<span class="sh-um-item-icon">'' || f_render_icon_span(v_icons(i)) || ''</span>'' ||',
'            ''<span class="sh-um-item-text">'' || apex_escape.html(v_text_tab(i)) || ''</span>'' ||',
'            ''</div>'';',
'    END LOOP;',
'',
'    IF v_is_inside_logout THEN',
'        v_items_html := v_items_html ||',
'            ''<div class="sh-um-separator"></div>'' ||',
'            ''<div class="sh-um-item sh-um-item--logout" data-link="'' ||',
'            apex_escape.html_attribute(',
'                apex_util.prepare_url(p_url => v_logout_link_attr)',
'            ) || ''" role="menuitem" tabindex="-1">'' ||',
'            ''<span class="sh-um-item-icon">'' || f_render_icon_span(v_logout_icon_raw) || ''</span>'' ||',
'            ''<span class="sh-um-item-text">'' || f_txt(''Abmelden'', ''Sign Out'') || ''</span>'' ||',
'            ''</div>'';',
'    END IF;',
'',
'    ----------------------------------------------------------------',
'    -- Build the trigger (avatar + name + email + status + chevron)',
'    ----------------------------------------------------------------',
'    v_html := ''<div id="'' || v_wrapper_id || ''" class="sh-um-wrapper" '' ||',
'        ''data-um-align="RIGHT" '' ||',
'        ''style="--sh-um-panel-bg:'' || f_color(v_dropdown_bg_attr, ''#FFFFFF'') || '';'' ||',
'               ''--sh-um-panel-hover:'' || f_color(v_dropdown_hover_attr, ''#F3F4F6'') || '';'' ||',
'               ''--sh-um-panel-text:'' || f_color(v_dropdown_text_attr, ''#111827'') || '';">'';',
'',
'    v_html := v_html || ''<div class="sh-um-trigger" tabindex="0" role="button" '' ||',
'        ''aria-haspopup="true" aria-expanded="false" aria-label="'' ||',
unistr('        apex_escape.html_attribute(f_txt(''Benutzermen\00FC'', ''User menu'')) || ''">'';'),
'',
'    -- Avatar',
'    IF v_show_image = ''Y'' THEN',
'        v_html := v_html ||',
'            ''<span class="sh-um-avatar sh-um-avatar--'' || LOWER(v_image_shape) || ''" '' ||',
'            ''style="width:'' || f_number(v_image_size_attr, 28) || ''px;height:'' || f_number(v_image_size_attr, 28) || ''px;'' ||',
'            CASE WHEN v_image_border_color IS NOT NULL',
'                 THEN ''border-color:'' || f_color(v_image_border_color, ''#E5E7EB'') || '';''',
'                 ELSE NULL END || ''">'';',
'',
'        IF v_image_data_uri IS NOT NULL THEN',
'            -- Base64 data URI - embedded as-is, see the comment where',
'            -- v_image_data_uri is built above for why it can''t go',
'            -- through apex_escape.html_attribute.',
'            v_html := v_html || ''<img src="'' || v_image_data_uri ||',
'                ''" alt="" class="sh-um-avatar-img">'';',
'        ELSIF v_image_src IS NOT NULL THEN',
'            v_html := v_html || ''<img src="'' ||',
'                apex_escape.html_attribute(v_image_src) ||',
'                ''" alt="" class="sh-um-avatar-img">'';',
'        ELSE',
'            v_html := v_html || ''<span class="sh-um-avatar-initials">'' ||',
'                apex_escape.html(f_initials(v_user_name)) || ''</span>'';',
'        END IF;',
'',
'        IF v_show_status = ''Y'' THEN',
'            v_html := v_html || ''<span class="sh-um-status-dot" style="background:'' ||',
'                f_color(v_status_color_attr, ''#22C55E'') || '';"></span>'';',
'        END IF;',
'',
'        v_html := v_html || ''</span>'';',
'    END IF;',
'',
'    -- Name / Email',
'    IF v_user_name IS NOT NULL OR v_user_email IS NOT NULL THEN',
'        v_html := v_html || ''<span class="sh-um-text">'';',
'        IF v_user_name IS NOT NULL THEN',
'            v_html := v_html || ''<span class="sh-um-name">'' || apex_escape.html(v_user_name) || ''</span>'';',
'        END IF;',
'        IF v_user_email IS NOT NULL THEN',
'            v_html := v_html || ''<span class="sh-um-email">'' || apex_escape.html(v_user_email) || ''</span>'';',
'        END IF;',
'        v_html := v_html || ''</span>'';',
'    END IF;',
'',
'    -- Chevron',
'    IF v_show_dropdown = ''Y'' AND v_show_chevron = ''Y'' THEN',
'        v_html := v_html || ''<span class="sh-um-chevron" aria-hidden="true"></span>'';',
'    END IF;',
'',
'    v_html := v_html || ''</div>''; -- .sh-um-trigger',
'',
'    -- Outside logout button. Class carries the selected Logout Style',
'    -- (sh-um-logout-outside--style1..4) so CSS alone controls the',
'    -- visual variant - no JS changes required. Style3/Style4 also get',
'    -- a text label next to the icon.',
'    IF v_is_outside_logout THEN',
'        v_html := v_html || ''<a class="sh-um-logout-outside sh-um-logout-outside--'' ||',
'            LOWER(v_logout_style) || ''" href="'' ||',
'            apex_escape.html_attribute(',
'                apex_util.prepare_url(p_url => v_logout_link_attr)',
'            ) || ''" aria-label="'' || apex_escape.html_attribute(f_txt(''Abmelden'', ''Sign Out'')) ||',
'            ''" title="'' || apex_escape.html_attribute(f_txt(''Abmelden'', ''Sign Out'')) || ''">'' ||',
'            f_render_icon_span(v_logout_icon_raw);',
'',
'        IF v_logout_style IN (''STYLE3'', ''STYLE4'') THEN',
'            v_html := v_html || ''<span class="sh-um-logout-outside-text">'' ||',
'                apex_escape.html(f_txt(''Abmelden'', ''Sign Out'')) || ''</span>'';',
'        END IF;',
'',
'        v_html := v_html || ''</a>'';',
'    END IF;',
'',
'    v_html := v_html || ''</div>''; -- .sh-um-wrapper',
'',
'    ----------------------------------------------------------------',
'    -- Dropdown panel markup (hidden by default, moved to <body> by JS)',
'    ----------------------------------------------------------------',
'    IF v_show_dropdown = ''Y'' THEN',
'        v_html := v_html ||',
'            ''<div id="'' || v_panel_id || ''" class="sh-um-panel" role="menu" '' ||',
'            ''aria-hidden="true" '' ||',
'            ''style="--sh-um-panel-bg:'' || f_color(v_dropdown_bg_attr, ''#FFFFFF'') || '';'' ||',
'                   ''--sh-um-panel-hover:'' || f_color(v_dropdown_hover_attr, ''#F3F4F6'') || '';'' ||',
'                   ''--sh-um-panel-text:'' || f_color(v_dropdown_text_attr, ''#111827'') || '';">'' ||',
'            ''<div class="sh-um-panel-items">'' || v_items_html || ''</div>'' ||',
'            ''</div>'';',
'    END IF;',
'',
'    ----------------------------------------------------------------',
'    -- Output + JS init call',
'    ----------------------------------------------------------------',
'    p_print_clob(v_html);',
'',
'    -- The Base64 image data came from a temporary CLOB',
'    -- (APEX_WEB_SERVICE.BLOB2CLOBBASE64) and has now been fully',
'    -- copied into v_html by the concatenation above and flushed out -',
'    -- free it so the session doesn''t accumulate temporary LOB space',
'    -- across page views.',
'    IF v_image_base64 IS NOT NULL AND DBMS_LOB.ISTEMPORARY(v_image_base64) = 1 THEN',
'        DBMS_LOB.FREETEMPORARY(v_image_base64);',
'    END IF;',
'',
'    IF v_show_dropdown = ''Y'' THEN',
'        apex_javascript.add_onload_code(',
'            p_code => ''SH_USER_MENU.init('' || apex_javascript.add_value(v_wrapper_id) || '');''',
'        );',
'    END IF;',
'',
'    RETURN v_result;',
'END render;'))
,p_default_escape_mode=>'HTML'
,p_api_version=>2
,p_render_function=>'render'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_files_version=>117
);
end;
/
begin
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(111775194587254509)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_title=>unistr('\D83D\DEAA Logout')
,p_display_sequence=>30
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(111775595025254509)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_title=>unistr('\D83D\DCCB Dropdown Menu')
,p_display_sequence=>40
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(111774781193254510)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_title=>unistr('\D83E\DDD1 User Display')
,p_display_sequence=>10
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(114463725588484571)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_title=>unistr('\D83D\DDBC\FE0F Profile Image')
,p_display_sequence=>20
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111776267527042078)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>400
,p_prompt=>unistr('\D83D\DDBC\FE0F Show Image')
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(114463725588484571)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>Y</code> \2014 show avatar'),
unistr('\2705 <code>N</code> \2014 hide avatar entirely')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Controls whether the avatar (photo/initials) is shown in the trigger. Accepts <strong>Y</strong> or <strong>N</strong>.<br><br>',
unistr('\26A0\FE0F When set to <strong>N</strong>, Image Source, Image MIME Type, Image Shape, Border Color, Show Status, and Status Color are all ignored.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111776861855034785)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>500
,p_prompt=>unistr('\D83C\DF10 Image Source')
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'SUPER_ADMIN.SUAD_EMAIL.SUAD_PROFILE_BLOB'
,p_max_length=>4000
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111776267527042078)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(114463725588484571)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>SUPER_ADMIN.SUAD_EMAIL.SUAD_PROFILE_BLOB</code> \2014 database BLOB, Base64-embedded'),
unistr('\2705 <code>https://example.com/avatar.jpg</code> \2014 literal image URL'),
unistr('\2705 <code>&P3_PHOTO_URL.</code> \2014 plain item reference'),
unistr('\26D4 (left empty) \2014 falls back to initials')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('A literal image URL \2014 OR a <strong>TABLE.MATCH_COLUMN.VALUE_COLUMN</strong> reference (e.g. <code>SUPER_ADMIN.SUAD_EMAIL.SUAD_PROFILE_BLOB</code>) pointing to a BLOB column to embed automatically as Base64.<br><br>'),
unistr('\26A0\FE0F Images larger than 300 KB automatically fall back to initials instead of failing the page.<br>'),
unistr('\26A0\FE0F When using the BLOB/database format, Image MIME Type below must also be configured, or it defaults to <code>image/png</code>.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111777495591025939)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>700
,p_prompt=>unistr('\D83D\DD35 Image Shape')
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111776267527042078)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(114463725588484571)
,p_null_text=>'-- Please Select --'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 Round \2014 fully circular'),
unistr('\2705 Square \2014 sharp corners'),
unistr('\2705 Rounded \2014 soft rounded corners')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Controls the avatar''s border-radius shape. Choose from the static list.<br><br>',
unistr('\26A0\FE0F Defaults to <strong>Round</strong> if left unset.')))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(111778032179023018)
,p_plugin_attribute_id=>wwv_flow_imp.id(111777495591025939)
,p_display_sequence=>10
,p_display_value=>'Round'
,p_return_value=>'ROUND'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(111778401189019287)
,p_plugin_attribute_id=>wwv_flow_imp.id(111777495591025939)
,p_display_sequence=>20
,p_display_value=>'Square'
,p_return_value=>'SQUARE'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(111778817300017910)
,p_plugin_attribute_id=>wwv_flow_imp.id(111777495591025939)
,p_display_sequence=>30
,p_display_value=>'Rounded'
,p_return_value=>'ROUNDED'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111824899446387366)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>800
,p_prompt=>unistr('\D83C\DFA8 Border Color')
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_default_value=>'#000000'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111776267527042078)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(114463725588484571)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>#DBEAFE</code><br>'),
unistr('\2705 <code>#FFF</code><br>'),
unistr('\274C <code>light blue</code> \2014 not a hex code, ignored<br>'),
unistr('\D83D\DEAB <i>(left empty)</i> \2014 no border')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Optional border color drawn around the avatar edge.<br><br>',
unistr('Must be a valid <strong>#RRGGBB</strong> or <strong>#RGB</strong> hex value \2014 anything else is silently ignored and no border is drawn.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111825464741378842)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>100
,p_prompt=>unistr('\D83D\DC64 First Name')
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'SUPER_ADMIN.SUAD_EMAIL.SUAD_FIRST_NAME'
,p_max_length=>4000
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(111774781193254510)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>SUPER_ADMIN.SUAD_EMAIL.SUAD_FIRST_NAME</code> \2014 database lookup, matched via SUAD_EMAIL against APP_USER'),
unistr('\2705 <code>&P3_DISPLAY_NAME.</code> \2014 plain item reference'),
unistr('\2705 <code>John</code> \2014 hardcoded literal text'),
unistr('\26D4 (left empty) \2014 no first name shown')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('The user''s first name \2014 OR a <strong>TABLE.MATCH_COLUMN.VALUE_COLUMN</strong> reference (e.g. <code>SUPER_ADMIN.SUAD_EMAIL.SUAD_FIRST_NAME</code>) to have the plugin look this value up automatically, matched against the current APP_USER via the MATCH')
||'_COLUMN.<br><br>',
unistr('\26A0\FE0F This is fully independent of the Email attribute below \2014 each attribute runs its own lookup and does not require Email to also be configured.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111826002616374906)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>300
,p_prompt=>unistr('\2709\FE0F Email')
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'SUPER_ADMIN.SUAD_EMAIL.SUAD_EMAIL'
,p_max_length=>4000
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(111774781193254510)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>SUPER_ADMIN.SUAD_EMAIL.SUAD_EMAIL</code> \2014 database lookup, matched via SUAD_EMAIL against APP_USER'),
unistr('\2705 <code>&P3_EMAIL.</code> \2014 plain item reference'),
unistr('\2705 <code>test@test.de</code> \2014 hardcoded literal text'),
unistr('\26D4 (left empty) \2014 falls back to APP_USER automatically')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('The user''s email \2014 OR a <strong>TABLE.MATCH_COLUMN.VALUE_COLUMN</strong> reference (e.g. <code>SUPER_ADMIN.SUAD_EMAIL.SUAD_EMAIL</code>) to have the plugin look this value up, matched against the current APP_USER via the MATCH_COLUMN.<br><br>'),
unistr('\26A0\FE0F This is a standalone lookup, fully independent of First Name/Last Name/Image Source/Image MIME Type above and below \2014 it does not act as their matching key. Each attribute runs its own lookup separately.<br>'),
unistr('\26A0\FE0F If a database lookup finds no matching row, the current APP_USER is shown instead \2014 Email is never left blank in that case.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111826605534338083)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>900
,p_prompt=>unistr('\D83D\DFE2 Show Status')
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(114463725588484571)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>Yes</code> \2014 dot shown, colored per <strong>Status Color</strong><br>'),
unistr('\D83D\DEAB <code>No</code> \2014 no dot')))
,p_help_text=>unistr('Displays a small colored dot on the bottom-right corner of the avatar \2014 commonly used to indicate an <strong>online</strong> state.')
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111827230052333270)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>1000
,p_prompt=>unistr('\D83C\DFA8 Status Color')
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_default_value=>'#22C55E'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111826605534338083)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(114463725588484571)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>#22C55E</code> \2014 green, "online"<br>'),
unistr('\2705 <code>#EF4444</code> \2014 red, "busy"')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Color of the status dot described above.<br><br>',
'Only visible when <strong>Show Status</strong> = Yes. Must be a valid hex color.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111827997382322644)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>unistr('\D83D\DD0C Show Logout Button')
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(111775194587254509)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>Yes</code><br>'),
unistr('\D83D\DEAB <code>No</code> \2014 logout fully hidden')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Controls whether a logout option is shown at all. Accepts <strong>Y</strong> or <strong>N</strong>.<br><br>',
unistr('\26A0\FE0F When set to <strong>N</strong>, Logout Target, Logout Icon, Logout Position, and Logout Style are all ignored.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(112195088187074919)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>200
,p_prompt=>unistr('\D83D\DD17 Logout Target')
,p_attribute_type=>'LINK'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111827997382322644)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(111775194587254509)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>Target: Page in this Application',
'Page: 9999',
'Set Items: P9999_LOGOUT_YN',
'With Values: YES</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Where clicking <strong>Sign Out</strong> navigates to.<br><br>',
unistr('Use the Link Builder to target a page in this application \2014 typically the page/process that ends the session, with an item/value pair that triggers it.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111829247311306797)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>300
,p_prompt=>unistr('\D83C\DFAF Logout Icon')
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_common=>false
,p_show_in_wizard=>false
,p_default_value=>'fa-sign-out'
,p_max_length=>255
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111827997382322644)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(111775194587254509)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>fa-sign-out</code><br>'),
unistr('\2705 <code>fa-right-from-bracket</code> \2014 Font Awesome icon, inherited color'),
unistr('\2705 <code>fa-right-from-bracket|#DC2626</code> \2014 Font Awesome icon, red'),
unistr('\2705 <code>\D83D\DC4B</code> \2014 plain emoji, rendered as text'),
unistr('\2705 <code>\D83D\DEAA|#7A2941</code> \2014 emoji with a custom color')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'A Font Awesome icon shorthand, OR any plain text/emoji, optionally followed by <strong>|#hexcolor</strong> to override its color.<br><br>',
unistr('\26A0\FE0F Defaults to <code>fa-right-from-bracket</code> if left empty.<br>'),
unistr('\26A0\FE0F An invalid color after "|" is silently dropped \2014 the icon still renders, just without a custom color.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111829818843301036)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>400
,p_prompt=>unistr('\D83D\DCCD Logout Position')
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_common=>false
,p_show_in_wizard=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111827997382322644)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(111775194587254509)
,p_null_text=>'-- Please Select --'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>OUTSIDE</code><br>'),
unistr('\2705 <code>INSIDE</code>')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Controls where the logout option appears. Choose from the static list.<br><br>',
'<strong>Outside Dropdown</strong>: standalone, always-visible icon button next to the name/email.<br><br>',
'<strong>Inside Dropdown Menu</strong>: adds Sign Out as the last dropdown entry, below a divider.<br><br>',
unistr('\26A0\FE0F Only one of the two can be active at a time.<br>'),
unistr('\26A0\FE0F Logout Style below only applies when set to Outside Dropdown.')))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(111830434934299172)
,p_plugin_attribute_id=>wwv_flow_imp.id(111829818843301036)
,p_display_sequence=>10
,p_display_value=>'Outside Dropdown'
,p_return_value=>'OUTSIDE'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(111830843827290634)
,p_plugin_attribute_id=>wwv_flow_imp.id(111829818843301036)
,p_display_sequence=>20
,p_display_value=>'Inside Dropdown Menu'
,p_return_value=>'INSIDE '
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111831597964280507)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>100
,p_prompt=>unistr('\2B07\FE0F Enable Dropdown')
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(111775595025254509)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>Yes</code><br>'),
unistr('\D83D\DEAB <code>No</code> \2014 no chevron, no panel, nothing clickable')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('Master switch for the entire dropdown feature \2014 chevron, panel, and every menu entry inside it.<br><br>'),
unistr('\D83D\DEAB Turn off for a simple, non-clickable profile display with no menu at all.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(113744824392118365)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>200
,p_prompt=>unistr('\D83D\DDC2\FE0F Dropdown Menu Query')
,p_attribute_type=>'SQL'
,p_is_required=>false
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- icon: "fa-xxx" or "fa-xxx|#hexcolor" or "text/emoji" or "text/emoji|#hexcolor"',
'-- Font APEX names only (FA4-based) - not fa-pen/fa-triangle-exclamation etc.',
'',
'SELECT ''fa-user''                                  AS icon,',
'       ''My Profile''                               AS dropdown_text,',
'       apex_page.get_url(p_page => 10)            AS link,',
'       ''MAIN''                                     AS menu_type',
'FROM dual',
'UNION ALL',
'SELECT ''fa-pencil|#6B7280'',',
'       ''Edit Profile'',',
'       apex_page.get_url(p_page => 10, p_items => ''P10_MODE'', p_values => ''EDIT''),',
'       ''SUB''',
'FROM dual',
'UNION ALL',
'SELECT ''fa-image|#6B7280'',',
'       ''Change Photo'',',
'       apex_page.get_url(p_page => 10, p_items => ''P10_MODE,P10_SECTION'', p_values => ''EDIT,PHOTO''),',
'       ''SUB''',
'FROM dual',
'UNION ALL',
unistr('SELECT ''\D83D\DD14'','),
'       ''Notifications'',',
'       apex_page.get_url(p_page => 11),',
'       ''MAIN''',
'FROM dual',
'UNION ALL',
'SELECT ''fa-envelope|#2563EB'',',
'       ''Email Preferences'',',
'       apex_page.get_url(p_page => 11, p_items => ''P11_TAB'', p_values => ''EMAIL''),',
'       ''SUB''',
'FROM dual',
'UNION ALL',
unistr('SELECT ''\D83D\DCF1|#22C55E'','),
'       ''Push Notifications'',',
'       apex_page.get_url(p_page => 11, p_items => ''P11_TAB'', p_values => ''PUSH''),',
'       ''SUB''',
'FROM dual',
'UNION ALL',
'SELECT ''fa-exclamation-triangle|#F59E0B'',',
'       ''Billing'',',
'       apex_page.get_url(p_page => 50),',
'       ''MAIN''',
'FROM dual',
'UNION ALL',
unistr('SELECT ''\20AC|#2563EB'','),
'       ''Invoices'',',
'       apex_page.get_url(p_page => 50, p_items => ''P50_TAB'', p_values => ''INVOICES''),',
'       ''SUB''',
'FROM dual',
'UNION ALL',
'SELECT ''fa-credit-card|#6B7280'',',
'       ''Payment Methods'',',
'       apex_page.get_url(p_page => 50, p_items => ''P50_TAB'', p_values => ''PAYMENT''),',
'       ''SUB''',
'FROM dual',
'UNION ALL',
unistr('SELECT ''\D83D\DCAC'','),
'       ''Support'',',
'       apex_page.get_url(p_page => 60),',
'       ''MAIN''',
'FROM dual',
'UNION ALL',
unistr('SELECT ''\D83D\DCAC|#25D366'','),
'       ''WhatsApp Support'',',
'       ''https://wa.me/4917643477786'',',
'       ''SUB''',
'FROM dual',
'UNION ALL',
'SELECT ''fa-envelope'',',
'       ''Email Support'',',
'       ''mailto:support@shsoftwaresolution.com'',',
'       ''SUB''',
'FROM dual',
'UNION ALL',
'SELECT ''fa-gear'',',
'       ''Settings'',',
'       apex_page.get_url(p_page => 900),',
'       ''MAIN''',
'FROM dual',
'UNION ALL',
'SELECT ''?|#6B7280'',',
'       ''Help & Support'',',
'       ''https://shsoftwaresolution.com'',',
'       ''MAIN''',
'FROM dual'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111831597964280507)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(111775595025254509)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>SELECT ''fa-gear'', ''Settings'', ''f?p=&APP_ID.:900:&SESSION.::::'', ''MAIN'' FROM dual</code>'),
unistr('\2705 <code>SELECT ''\2699\FE0F|#7A2941'', ''Preferences'', ''f?p=&APP_ID.:50:&SESSION.::::'', ''SUB'' FROM dual</code>'),
unistr('\26D4 A query returning fewer or more than 4 columns \2014 will fail and the dropdown renders empty')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'A SQL query returning exactly <strong>4 columns, in this order</strong>: icon, text, link, menu_type.<br><br>',
'<strong>icon</strong>: Font Awesome shorthand (<code>fa-gear</code>) or plain text/emoji, optionally with <code>|#hexcolor</code>.<br>',
'<strong>text</strong>: the menu item''s label.<br>',
'<strong>link</strong>: target page or URL.<br>',
'<strong>menu_type</strong>: <code>MAIN</code> for a top-level bold row, or <code>SUB</code> for an indented row underneath it.<br><br>',
unistr('\26A0\FE0F If left empty, a built-in default 2-item menu is used.<br>'),
unistr('\26A0\FE0F If the query fails at runtime, it''s caught safely \2014 the dropdown just renders empty rather than breaking the page.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111832764784243389)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>300
,p_prompt=>unistr('\2304 Show Chevron Icon')
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_is_common=>false
,p_show_in_wizard=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111831597964280507)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(111775595025254509)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>Yes</code><br>'),
unistr('\D83D\DEAB <code>No</code> \2014 arrow hidden, menu still works')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Controls whether the small chevron arrow is shown next to the name/email, indicating the dropdown can be opened. Accepts <strong>Y</strong> or <strong>N</strong>.<br><br>',
unistr('\26A0\FE0F Purely cosmetic \2014 the dropdown still opens on click even if the chevron is hidden, as long as Enable Dropdown above is <strong>Y</strong>.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111833391015238268)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>17
,p_display_sequence=>400
,p_prompt=>unistr('\D83C\DFA8 Dropdown Background Color')
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_is_common=>false
,p_show_in_wizard=>false
,p_default_value=>'#FFFFFF'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111831597964280507)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(111775595025254509)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>#FFFFFF</code> \2014 white (default)'),
unistr('\2705 <code>#1F2937</code> \2014 dark panel'),
unistr('\26D4 <code>white</code> \2014 named colors are not supported, hex only')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Hex color for the dropdown panel''s background. Must be a valid 3 or 6-digit hex code starting with <strong>#</strong>.<br><br>',
unistr('\26A0\FE0F Defaults to <strong>#FFFFFF</strong> (white) if left empty or invalid.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111833913937230022)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>500
,p_prompt=>unistr('\D83C\DFA8 Menu Item Hover Color')
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_is_common=>false
,p_show_in_wizard=>false
,p_default_value=>'#c59595'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111831597964280507)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(111775595025254509)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>#c59595</code>'),
unistr('\2705 <code>#F3F4F6</code> \2014 light gray (default)'),
unistr('\2705 <code>#374151</code> \2014 dark hover, for a dark panel background'),
unistr('\26D4 <code>lightgray</code> \2014 named colors are not supported, hex only')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Hex color shown behind a dropdown item on hover/focus. Must be a valid 3 or 6-digit hex code starting with <strong>#</strong>.<br><br>',
unistr('\26A0\FE0F Defaults to <strong>#c59595</strong> (light gray) if left empty or invalid.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(111834536965225027)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>19
,p_display_sequence=>600
,p_prompt=>unistr('\D83C\DFA8 Text Color')
,p_attribute_type=>'COLOR'
,p_is_required=>false
,p_is_common=>false
,p_show_in_wizard=>false
,p_default_value=>'#111827'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111831597964280507)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(111775595025254509)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>#111827</code> \2014 near-black (default)'),
unistr('\2705 <code>#F9FAFB</code> \2014 near-white, for a dark panel background'),
unistr('\26D4 <code>black</code> \2014 named colors are not supported, hex only')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Hex color for the dropdown menu items'' text. Must be a valid 3 or 6-digit hex code starting with <strong>#</strong>.<br><br>',
unistr('\26A0\FE0F Defaults to <strong>#111827</strong> (near-black) if left empty or invalid.<br>'),
unistr('\26A0\FE0F Choose a color with enough contrast against Dropdown Background Color above \2014 this attribute does not auto-adjust for readability.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(112182580878397451)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>22
,p_display_sequence=>200
,p_prompt=>unistr('\D83D\DC64 Last Name')
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'SUPER_ADMIN.SUAD_EMAIL.SUAD_LAST_NAME'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(111774781193254510)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>SUPER_ADMIN.SUAD_EMAIL.SUAD_LAST_NAME</code> \2014 database lookup, matched via SUAD_EMAIL against APP_USER'),
unistr('\2705 <code>&P3_LAST_NAME.</code> \2014 plain item reference'),
unistr('\2705 <code>Doe</code> \2014 hardcoded literal text'),
unistr('\26D4 (left empty) \2014 no last name shown')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('The user''s last name \2014 OR a <strong>TABLE.MATCH_COLUMN.VALUE_COLUMN</strong> reference (e.g. <code>SUPER_ADMIN.SUAD_EMAIL.SUAD_LAST_NAME</code>) to have the plugin look this value up automatically, matched against the current APP_USER via the MATCH_C')
||'OLUMN.<br><br>',
unistr('\26A0\FE0F This is fully independent of the Email attribute below \2014 each attribute runs its own lookup and does not require Email to also be configured.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(113578953139265127)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>23
,p_display_sequence=>600
,p_prompt=>unistr('\D83E\DDFE Image MIME Type')
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'SUPER_ADMIN.SUAD_EMAIL.SUAD_PROFILE_MIME'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111776267527042078)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_attribute_group_id=>wwv_flow_imp.id(114463725588484571)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>SUPER_ADMIN.SUAD_EMAIL.SUAD_PROFILE_MIME</code> \2014 database lookup'),
unistr('\26D4 (left empty) \2014 defaults to image/png'),
unistr('\26D4 <code>image/png</code> \2014 do NOT hardcode here; this attribute expects a TABLE.MATCH.VALUE reference, not a literal MIME string')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Only used when Image Source above is a database BLOB reference. Must be a <strong>TABLE.MATCH_COLUMN.VALUE_COLUMN</strong> reference pointing to the column that stores the image''s MIME type (e.g. <code>image/png</code>, <code>image/jpeg</code>).<br><'
||'br>',
unistr('\26A0\FE0F If left empty or the lookup fails, defaults silently to <code>image/png</code> \2014 never breaks the page.<br>'),
unistr('\26A0\FE0F Ignored completely when Image Source is a literal URL, not a BLOB reference.')))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(114438383392807508)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>24
,p_display_sequence=>500
,p_prompt=>unistr('\D83C\DFA8 Logout Style')
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'STYLE1'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(111829818843301036)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'OUTSIDE'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(111775194587254509)
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('\2705 <code>STYLE1</code> \2014 Icon Only'),
unistr('\2705 <code>STYLE2</code> \2014 Icon Outlined'),
unistr('\2705 <code>STYLE3</code> \2014 Icon + Text'),
unistr('\2705 <code>STYLE4</code> \2014 Solid Button')))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Controls the visual style of the <strong>Outside Dropdown</strong> logout button only. Choose from the static list.<br><br>',
'<strong>Icon Only</strong>: compact icon button, ghost hover.<br>',
'<strong>Icon Outlined</strong>: icon in an outlined circle, always visible.<br>',
'<strong>Icon + Text</strong>: icon with a "Sign Out" label.<br>',
'<strong>Solid Button</strong>: filled button with icon and label.<br><br>',
unistr('\26A0\FE0F Only visible/applies when Logout Position above is set to Outside Dropdown \2014 has no effect on Inside Dropdown Menu, where the Sign Out row always uses the standard dropdown item style.')))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(114439590758773348)
,p_plugin_attribute_id=>wwv_flow_imp.id(114438383392807508)
,p_display_sequence=>10
,p_display_value=>unistr('Style 1 \2192 Icon Only')
,p_return_value=>'STYLE1'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(114439976639770897)
,p_plugin_attribute_id=>wwv_flow_imp.id(114438383392807508)
,p_display_sequence=>20
,p_display_value=>unistr('Style 2 \2192 Icon Outlined')
,p_return_value=>'STYLE2'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(114440326443767425)
,p_plugin_attribute_id=>wwv_flow_imp.id(114438383392807508)
,p_display_sequence=>30
,p_display_value=>unistr('Style 3 \2192 Icon + Text')
,p_return_value=>'STYLE3'
);
end;
/
begin
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(114440780092765405)
,p_plugin_attribute_id=>wwv_flow_imp.id(114438383392807508)
,p_display_sequence=>40
,p_display_value=>unistr('Style 4 \2192 Solid Button')
,p_return_value=>'STYLE4'
);
null;
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A20202053264820536F66747761726520536F6C7574';
wwv_flow_imp.g_varchar2_table(2) := '696F6E73202D2055736572204D656E7520526567696F6E20506C7567696E0D0A2020205072656669783A2073682D756D2D2A20202861766F69647320636F6C6C6973696F6E73207769746820556E6976657273616C205468656D65202F20415045582049';
wwv_flow_imp.g_varchar2_table(3) := '4473290D0A2020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A20202056657273696F6E3A20312E312E';
wwv_flow_imp.g_varchar2_table(4) := '30202D2044726F70646F776E2070616E656C207769647468206973206E6F7720636F6E74656E742D626173656420286D696E2F6D61780D0A202020626F756E647320696E7374656164206F6620612066697865642070782076616C75652066726F6D2061';
wwv_flow_imp.g_varchar2_table(5) := '6E20617474726962757465292E204E65770D0A2020202E73682D756D2D6974656D2D69636F6E2D7465787420636C61737320666F7220706C61696E20746578742F656D6F6A692069636F6E7320286173206F70706F7365640D0A202020746F206120466F';
wwv_flow_imp.g_varchar2_table(6) := '6E7420417765736F6D652069636F6E2D666F6E7420636C617373292E0D0A2020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_imp.g_varchar2_table(7) := '3D3D3D3D3D3D3D202A2F0D0A0D0A2E73682D756D2D77726170706572207B0D0A20202020706F736974696F6E3A2072656C61746976653B0D0A20202020646973706C61793A20696E6C696E652D666C65783B0D0A20202020616C69676E2D6974656D733A';
wwv_flow_imp.g_varchar2_table(8) := '2063656E7465723B0D0A202020206761703A203870783B0D0A7D0D0A0D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(9) := '2D202A2F0D0A2F2A20547269676765722028617661746172202B206E616D652F656D61696C202B2063686576726F6E292020202020202020202020202020202020202020202020202020202020202A2F0D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(10) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0D0A0D0A2E73682D756D2D74726967676572207B0D0A20202020646973706C61793A20696E6C696E652D666C';
wwv_flow_imp.g_varchar2_table(11) := '65783B0D0A20202020616C69676E2D6974656D733A2063656E7465723B0D0A202020206761703A20313070783B0D0A2020202070616464696E673A20347078203870783B0D0A20202020626F726465722D7261646975733A203870783B0D0A2020202063';
wwv_flow_imp.g_varchar2_table(12) := '7572736F723A20706F696E7465723B0D0A202020206F75746C696E653A206E6F6E653B0D0A202020207472616E736974696F6E3A206261636B67726F756E642D636F6C6F7220302E31357320656173653B0D0A7D0D0A0D0A2E73682D756D2D7472696767';
wwv_flow_imp.g_varchar2_table(13) := '65723A686F7665722C0D0A2E73682D756D2D777261707065722E69732D616374697665202E73682D756D2D74726967676572207B0D0A202020206261636B67726F756E642D636F6C6F723A207267626128302C20302C20302C20302E3034293B0D0A7D0D';
wwv_flow_imp.g_varchar2_table(14) := '0A0D0A2E73682D756D2D747269676765723A666F6375732D76697369626C65207B0D0A20202020626F782D736861646F773A2030203020302032707820726762612835392C203133302C203234362C20302E35292021696D706F7274616E743B0D0A7D0D';
wwv_flow_imp.g_varchar2_table(15) := '0A0D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0D0A2F2A20417661746172202020202020202020202020';
wwv_flow_imp.g_varchar2_table(16) := '202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202A2F0D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(17) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0D0A0D0A2E73682D756D2D617661746172207B0D0A20202020706F736974696F6E3A2072656C61746976653B0D0A20202020666C65783A20302030206175746F3B0D0A202020';
wwv_flow_imp.g_varchar2_table(18) := '20646973706C61793A20696E6C696E652D666C65783B0D0A20202020616C69676E2D6974656D733A2063656E7465723B0D0A202020206A7573746966792D636F6E74656E743A2063656E7465723B0D0A202020206F766572666C6F773A2068696464656E';
wwv_flow_imp.g_varchar2_table(19) := '3B0D0A202020206261636B67726F756E642D636F6C6F723A20234535453745423B0D0A20202020626F726465723A2031707820736F6C6964207472616E73706172656E743B0D0A20202020626F782D73697A696E673A20626F726465722D626F783B0D0A';
wwv_flow_imp.g_varchar2_table(20) := '7D0D0A0D0A2E73682D756D2D6176617461722D2D726F756E64207B0D0A20202020626F726465722D7261646975733A203530252021696D706F7274616E743B0D0A7D0D0A0D0A2E73682D756D2D6176617461722D2D737175617265207B0D0A2020202062';
wwv_flow_imp.g_varchar2_table(21) := '6F726465722D7261646975733A20302021696D706F7274616E743B0D0A7D0D0A0D0A2E73682D756D2D6176617461722D2D726F756E646564207B0D0A20202020626F726465722D7261646975733A203870782021696D706F7274616E743B0D0A7D0D0A0D';
wwv_flow_imp.g_varchar2_table(22) := '0A2E73682D756D2D6176617461722D696D67207B0D0A2020202077696474683A20313030253B0D0A202020206865696768743A20313030253B0D0A202020206F626A6563742D6669743A20636F7665723B0D0A20202020646973706C61793A20626C6F63';
wwv_flow_imp.g_varchar2_table(23) := '6B3B0D0A7D0D0A0D0A2E73682D756D2D6176617461722D696E697469616C73207B0D0A20202020666F6E742D73697A653A20313370783B0D0A20202020666F6E742D7765696768743A203630303B0D0A20202020636F6C6F723A20233442353536333B0D';
wwv_flow_imp.g_varchar2_table(24) := '0A202020206C696E652D6865696768743A20313B0D0A20202020757365722D73656C6563743A206E6F6E653B0D0A7D0D0A0D0A2E73682D756D2D7374617475732D646F74207B0D0A20202020706F736974696F6E3A206162736F6C7574653B0D0A202020';
wwv_flow_imp.g_varchar2_table(25) := '20626F74746F6D3A202D3170783B0D0A2020202072696768743A202D3170783B0D0A2020202077696474683A20313070783B0D0A202020206865696768743A20313070783B0D0A20202020626F726465722D7261646975733A203530252021696D706F72';
wwv_flow_imp.g_varchar2_table(26) := '74616E743B0D0A20202020626F726465723A2032707820736F6C696420234646464646463B0D0A20202020626F782D73697A696E673A20636F6E74656E742D626F783B0D0A7D0D0A0D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(27) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0D0A2F2A204E616D65202F20456D61696C2020202020202020202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(28) := '202020202020202020202020202020202020202020202A2F0D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F';
wwv_flow_imp.g_varchar2_table(29) := '0D0A0D0A2E73682D756D2D74657874207B0D0A20202020646973706C61793A20666C65783B0D0A20202020666C65782D646972656374696F6E3A20636F6C756D6E3B0D0A202020206C696E652D6865696768743A20312E32353B0D0A2020202074657874';
wwv_flow_imp.g_varchar2_table(30) := '2D616C69676E3A206C6566743B0D0A2020202077686974652D73706163653A206E6F777261703B0D0A7D0D0A0D0A2E73682D756D2D6E616D65207B0D0A20202020666F6E742D73697A653A20313370783B0D0A20202020666F6E742D7765696768743A20';
wwv_flow_imp.g_varchar2_table(31) := '3630303B0D0A20202020636F6C6F723A20766172282D2D73682D756D2D6E616D652D636F6C6F722C2023464646464646293B0D0A7D0D0A0D0A2E73682D756D2D656D61696C207B0D0A20202020666F6E742D73697A653A20313270783B0D0A2020202063';
wwv_flow_imp.g_varchar2_table(32) := '6F6C6F723A20766172282D2D73682D756D2D656D61696C2D636F6C6F722C2023464646464646293B0D0A7D0D0A0D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(33) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0D0A2F2A2043686576726F6E2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202A2F0D0A';
wwv_flow_imp.g_varchar2_table(34) := '2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0D0A0D0A2E73682D756D2D63686576726F6E207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(35) := '666C65783A20302030206175746F3B0D0A2020202077696474683A203870783B0D0A202020206865696768743A203870783B0D0A20202020626F726465722D72696768743A20312E35707820736F6C696420236666666666663B0D0A20202020626F7264';
wwv_flow_imp.g_varchar2_table(36) := '65722D626F74746F6D3A20312E35707820736F6C696420236666666666663B0D0A202020207472616E73666F726D3A20726F74617465283435646567293B0D0A202020206D617267696E2D746F703A202D3370783B0D0A202020207472616E736974696F';
wwv_flow_imp.g_varchar2_table(37) := '6E3A207472616E73666F726D20302E31357320656173653B0D0A7D0D0A0D0A2E73682D756D2D777261707065722E69732D616374697665202E73682D756D2D63686576726F6E207B0D0A202020207472616E73666F726D3A20726F746174652832323564';
wwv_flow_imp.g_varchar2_table(38) := '6567293B0D0A202020206D617267696E2D746F703A203370783B0D0A7D0D0A0D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(39) := '2D2D2D2D202A2F0D0A2F2A204F757473696465206C6F676F757420627574746F6E202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202A2F0D0A2F2A202D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(40) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0D0A0D0A2F2A205368617265642062617365202D2076617269616E7420636C617373657320282D2D';
wwv_flow_imp.g_varchar2_table(41) := '7374796C65312E2E342920636F6E74726F6C2073697A652F73686170652F66696C6C202A2F0D0A2E73682D756D2D6C6F676F75742D6F757473696465207B0D0A20202020646973706C61793A20696E6C696E652D666C65783B0D0A20202020616C69676E';
wwv_flow_imp.g_varchar2_table(42) := '2D6974656D733A2063656E7465723B0D0A202020206A7573746966792D636F6E74656E743A2063656E7465723B0D0A20202020626F782D73697A696E673A20626F726465722D626F783B0D0A20202020636F6C6F723A20234646464646463B0D0A202020';
wwv_flow_imp.g_varchar2_table(43) := '20746578742D6465636F726174696F6E3A206E6F6E653B0D0A20202020666C65783A20302030206175746F3B0D0A20202020626F726465723A20312E35707820736F6C6964207472616E73706172656E743B0D0A202020207472616E736974696F6E3A20';
wwv_flow_imp.g_varchar2_table(44) := '6261636B67726F756E642D636F6C6F7220302E31357320656173652C20636F6C6F7220302E31357320656173652C20626F726465722D636F6C6F7220302E31357320656173653B0D0A7D0D0A0D0A2E73682D756D2D6C6F676F75742D6F7574736964652D';
wwv_flow_imp.g_varchar2_table(45) := '74657874207B0D0A20202020666F6E742D73697A653A20313370783B0D0A20202020666F6E742D7765696768743A203630303B0D0A2020202077686974652D73706163653A206E6F777261703B0D0A7D0D0A0D0A2F2A205374796C652031202D2069636F';
wwv_flow_imp.g_varchar2_table(46) := '6E206F6E6C792C2067686F737420686F76657220286F726967696E616C2064656661756C74206C6F6F6B29202A2F0D0A2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C6531207B0D0A2020202077696474683A20333270783B0D0A20';
wwv_flow_imp.g_varchar2_table(47) := '2020206865696768743A20333270783B0D0A20202020626F726465722D7261646975733A203870783B0D0A7D0D0A0D0A2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65313A686F766572207B0D0A202020206261636B67726F756E';
wwv_flow_imp.g_varchar2_table(48) := '642D636F6C6F723A20234646464646463B0D0A20202020636F6C6F723A20233741323934313B0D0A20202020626F782D736861646F773A20302032707820367078207267626128302C20302C20302C20302E3138293B0D0A7D0D0A0D0A2F2A205374796C';
wwv_flow_imp.g_varchar2_table(49) := '652032202D2069636F6E206F6E6C792C206F75746C696E656420636972636C6520616C776179732076697369626C65202A2F0D0A2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C6532207B0D0A2020202077696474683A2033337078';
wwv_flow_imp.g_varchar2_table(50) := '3B0D0A202020206865696768743A20333370783B0D0A20202020626F726465722D7261646975733A203530252021696D706F7274616E743B0D0A20202020626F726465722D636F6C6F723A20236666666666663B0D0A7D0D0A0D0A2E73682D756D2D6C6F';
wwv_flow_imp.g_varchar2_table(51) := '676F75742D6F7574736964652D2D7374796C65323A686F766572207B0D0A202020206261636B67726F756E642D636F6C6F723A20234646464646463B0D0A20202020626F726465722D636F6C6F723A20234646464646463B0D0A20202020636F6C6F723A';
wwv_flow_imp.g_varchar2_table(52) := '20233741323934313B0D0A20202020626F782D736861646F773A20302032707820367078207267626128302C20302C20302C20302E3138293B0D0A7D0D0A0D0A2F2A205374796C652033202D2069636F6E202B20746578742C2067686F737420686F7665';
wwv_flow_imp.g_varchar2_table(53) := '72202A2F0D0A2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C6533207B0D0A202020206865696768743A20333270783B0D0A2020202070616464696E673A203020313270783B0D0A20202020626F726465722D7261646975733A2038';
wwv_flow_imp.g_varchar2_table(54) := '70783B0D0A202020206761703A203670783B0D0A7D0D0A0D0A2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65333A686F766572207B0D0A202020206261636B67726F756E642D636F6C6F723A20234646464646463B0D0A20202020';
wwv_flow_imp.g_varchar2_table(55) := '636F6C6F723A20233741323934313B0D0A20202020626F782D736861646F773A20302032707820367078207267626128302C20302C20302C20302E3138293B0D0A7D0D0A0D0A2F2A205374796C652034202D20736F6C69642066696C6C65642062757474';
wwv_flow_imp.g_varchar2_table(56) := '6F6E2C2069636F6E202B2074657874202A2F0D0A2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C6534207B0D0A202020206865696768743A20333270783B0D0A2020202070616464696E673A203020313470783B0D0A20202020626F';
wwv_flow_imp.g_varchar2_table(57) := '726465722D7261646975733A203870783B0D0A202020206761703A203670783B0D0A202020206261636B67726F756E642D636F6C6F723A20234443323632363B0D0A20202020626F726465722D636F6C6F723A20234443323632363B0D0A20202020636F';
wwv_flow_imp.g_varchar2_table(58) := '6C6F723A20234646464646463B0D0A7D0D0A0D0A2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65343A686F766572207B0D0A202020206261636B67726F756E642D636F6C6F723A20234239314331433B0D0A20202020626F726465';
wwv_flow_imp.g_varchar2_table(59) := '722D636F6C6F723A20234239314331433B0D0A20202020636F6C6F723A20234646464646463B0D0A7D0D0A0D0A2F2A202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(60) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0D0A2F2A2044726F70646F776E2070616E656C2028706F7274616C656420746F203C626F64793E206279204A5329202020202020202020202020202020202020202020202020202020202A2F0D0A2F2A20';
wwv_flow_imp.g_varchar2_table(61) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D202A2F0D0A0D0A2E73682D756D2D70616E656C207B0D0A20202020646973706C';
wwv_flow_imp.g_varchar2_table(62) := '61793A206E6F6E653B0D0A20202020706F736974696F6E3A2066697865643B0D0A202020207A2D696E6465783A20393939393B0D0A202020202F2A20436F6E74656E742D626173656420776964746820696E7374656164206F6620612066697865642061';
wwv_flow_imp.g_varchar2_table(63) := '74747269627574652076616C75653A2067726F777320746F0D0A2020202020202066697420746865206C6F6E67657374206D656E75206974656D20746578742C20627574206E657665722062656C6F772F61626F76652074686573650D0A202020202020';
wwv_flow_imp.g_varchar2_table(64) := '20626F756E64732E204A5320706F736974696F6E73207468652070616E656C20627920616E63686F72696E6720697473205249474854206564676520746F0D0A202020202020207468652074726967676572277320726967687420656467652028736565';
wwv_flow_imp.g_varchar2_table(65) := '20706F736974696F6E50616E656C20696E20746865204A532066696C652920616E640D0A202020202020206C6574732069742067726F77204C454654574152442066726F6D2074686572652C20736F207468697320776F726B732077697468206E6F204A';
wwv_flow_imp.g_varchar2_table(66) := '530D0A202020202020206368616E676573206E65656465642E202A2F0D0A2020202077696474683A206D61782D636F6E74656E743B0D0A202020206D696E2D77696474683A2031383070783B0D0A202020206D61782D77696474683A2033363070783B0D';
wwv_flow_imp.g_varchar2_table(67) := '0A202020206261636B67726F756E642D636F6C6F723A20766172282D2D73682D756D2D70616E656C2D62672C2023464646464646293B0D0A20202020626F726465723A2031707820736F6C6964207267626128302C20302C20302C20302E3038293B0D0A';
wwv_flow_imp.g_varchar2_table(68) := '20202020626F726465722D7261646975733A20313070783B0D0A20202020626F782D736861646F773A2030203870782032347078207267626128302C20302C20302C20302E3132292C20302032707820367078207267626128302C20302C20302C20302E';
wwv_flow_imp.g_varchar2_table(69) := '3038293B0D0A2020202070616464696E673A203670783B0D0A20202020626F782D73697A696E673A20626F726465722D626F783B0D0A7D0D0A0D0A2E73682D756D2D70616E656C2E69732D6F70656E207B0D0A20202020646973706C61793A20626C6F63';
wwv_flow_imp.g_varchar2_table(70) := '6B3B0D0A20202020616E696D6174696F6E3A2073682D756D2D73776970652D696E20302E35732063756269632D62657A69657228302E33342C20312E342C20302E36342C20312920626F74683B0D0A7D0D0A0D0A406B65796672616D65732073682D756D';
wwv_flow_imp.g_varchar2_table(71) := '2D73776970652D696E207B0D0A202020203025207B0D0A20202020202020206F7061636974793A20303B0D0A20202020202020207472616E73666F726D3A207472616E736C61746558283630707829207363616C6528302E3936293B0D0A202020207D0D';
wwv_flow_imp.g_varchar2_table(72) := '0A2020202031303025207B0D0A20202020202020206F7061636974793A20313B0D0A20202020202020207472616E73666F726D3A207472616E736C61746558283029207363616C652831293B0D0A202020207D0D0A7D0D0A0D0A2E73682D756D2D70616E';
wwv_flow_imp.g_varchar2_table(73) := '656C2E69732D636C6F73696E67207B0D0A20202020646973706C61793A20626C6F636B3B0D0A20202020616E696D6174696F6E3A2073682D756D2D73776970652D6F757420302E33732063756269632D62657A69657228302E342C20302C20312C203129';
wwv_flow_imp.g_varchar2_table(74) := '20626F74683B0D0A20202020706F696E7465722D6576656E74733A206E6F6E653B0D0A7D0D0A0D0A406B65796672616D65732073682D756D2D73776970652D6F7574207B0D0A202020203025207B0D0A20202020202020206F7061636974793A20313B0D';
wwv_flow_imp.g_varchar2_table(75) := '0A20202020202020207472616E73666F726D3A207472616E736C61746558283029207363616C652831293B0D0A202020207D0D0A2020202031303025207B0D0A20202020202020206F7061636974793A20303B0D0A20202020202020207472616E73666F';
wwv_flow_imp.g_varchar2_table(76) := '726D3A207472616E736C61746558283630707829207363616C6528302E3936293B0D0A202020207D0D0A7D0D0A0D0A406B65796672616D65732073682D756D2D70616E656C2D6F7574207B0D0A202020203025207B0D0A20202020202020206F70616369';
wwv_flow_imp.g_varchar2_table(77) := '74793A20313B0D0A2020202020202020636C69702D706174683A20636972636C6528313431252061742031303025203025293B0D0A20202020202020207472616E73666F726D3A207363616C652831293B0D0A202020202020202066696C7465723A2062';
wwv_flow_imp.g_varchar2_table(78) := '6C757228307078293B0D0A202020207D0D0A2020202031303025207B0D0A20202020202020206F7061636974793A20303B0D0A2020202020202020636C69702D706174683A20636972636C652830252061742031303025203025293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(79) := '20207472616E73666F726D3A207363616C6528302E3932293B0D0A202020202020202066696C7465723A20626C757228367078293B0D0A202020207D0D0A7D0D0A0D0A2E73682D756D2D70616E656C2D6974656D73207B0D0A20202020646973706C6179';
wwv_flow_imp.g_varchar2_table(80) := '3A20666C65783B0D0A20202020666C65782D646972656374696F6E3A20636F6C756D6E3B0D0A7D0D0A0D0A2E73682D756D2D6974656D207B0D0A20202020646973706C61793A20666C65783B0D0A20202020616C69676E2D6974656D733A2063656E7465';
wwv_flow_imp.g_varchar2_table(81) := '723B0D0A202020206761703A20313070783B0D0A2020202070616464696E673A2038707820313070783B0D0A20202020626F726465722D7261646975733A203670783B0D0A20202020637572736F723A20706F696E7465723B0D0A20202020636F6C6F72';
wwv_flow_imp.g_varchar2_table(82) := '3A20766172282D2D73682D756D2D70616E656C2D746578742C2023313131383237293B0D0A20202020666F6E742D73697A653A20313370783B0D0A202020206F75746C696E653A206E6F6E653B0D0A7D0D0A0D0A2E73682D756D2D6974656D2D2D737562';
wwv_flow_imp.g_varchar2_table(83) := '207B0D0A2020202070616464696E672D6C6566743A20333070783B0D0A7D0D0A0D0A2E73682D756D2D6974656D3A686F7665722C0D0A2E73682D756D2D6974656D3A666F6375732D76697369626C65207B0D0A202020206261636B67726F756E642D636F';
wwv_flow_imp.g_varchar2_table(84) := '6C6F723A20766172282D2D73682D756D2D70616E656C2D686F7665722C2023463346344636293B0D0A20202020636F6C6F723A20234646464646463B0D0A7D0D0A0D0A2E73682D756D2D6974656D2D69636F6E207B0D0A20202020646973706C61793A20';
wwv_flow_imp.g_varchar2_table(85) := '696E6C696E652D666C65783B0D0A20202020616C69676E2D6974656D733A2063656E7465723B0D0A202020206A7573746966792D636F6E74656E743A2063656E7465723B0D0A2020202077696474683A20313870783B0D0A20202020666C65783A203020';
wwv_flow_imp.g_varchar2_table(86) := '30206175746F3B0D0A20202020636F6C6F723A20696E68657269743B0D0A202020206F7061636974793A20302E37353B0D0A7D0D0A0D0A2F2A20506C61696E20746578742F656D6F6A692069636F6E2076617269616E74202D207573656420696E737465';
wwv_flow_imp.g_varchar2_table(87) := '6164206F6620616E2069636F6E2D666F6E7420676C7970680D0A2020207768656E207468652064726F70646F776E20717565727927732069636F6E20636F6C756D6E2069736E27742061202266612D2E2E2E222076616C756520287365650D0A20202066';
wwv_flow_imp.g_varchar2_table(88) := '5F72656E6465725F69636F6E5F7370616E20696E207468652072656E6465722066756E6374696F6E292E205369747320696E73696465207468652053414D450D0A2020202E73682D756D2D6974656D2D69636F6E20777261707065722061732074686520';
wwv_flow_imp.g_varchar2_table(89) := '466F6E7420417765736F6D652076617269616E742C20736F20726F770D0A202020616C69676E6D656E74207374617973206964656E746963616C20656974686572207761792E202A2F0D0A2E73682D756D2D6974656D2D69636F6E2D74657874207B0D0A';
wwv_flow_imp.g_varchar2_table(90) := '20202020646973706C61793A20696E6C696E652D626C6F636B3B0D0A20202020666F6E742D73697A653A20313470783B0D0A202020206C696E652D6865696768743A20313B0D0A20202020666F6E742D7374796C653A206E6F726D616C3B0D0A7D0D0A0D';
wwv_flow_imp.g_varchar2_table(91) := '0A2E73682D756D2D6974656D2D74657874207B0D0A20202020666C65783A20312031206175746F3B0D0A2020202077686974652D73706163653A206E6F777261703B0D0A202020206F766572666C6F773A2068696464656E3B0D0A20202020746578742D';
wwv_flow_imp.g_varchar2_table(92) := '6F766572666C6F773A20656C6C69707369733B0D0A7D0D0A0D0A2E73682D756D2D736570617261746F72207B0D0A202020206865696768743A203170783B0D0A202020206D617267696E3A20367078203470783B0D0A202020206261636B67726F756E64';
wwv_flow_imp.g_varchar2_table(93) := '2D636F6C6F723A207267626128302C20302C20302C20302E3038293B0D0A7D0D0A0D0A2E73682D756D2D6974656D2D2D6C6F676F7574207B0D0A20202020636F6C6F723A20234443323632363B0D0A7D0D0A0D0A2E73682D756D2D6974656D2D2D6C6F67';
wwv_flow_imp.g_varchar2_table(94) := '6F75743A686F7665722C0D0A2E73682D756D2D6974656D2D2D6C6F676F75743A666F6375732D76697369626C65207B0D0A202020206261636B67726F756E642D636F6C6F723A2072676261283232302C2033382C2033382C20302E3038293B0D0A202020';
wwv_flow_imp.g_varchar2_table(95) := '20636F6C6F723A20234443323632363B0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(111782937235519152)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_file_name=>'profile_bar.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A20202053264820536F66747761726520536F6C7574';
wwv_flow_imp.g_varchar2_table(2) := '696F6E73202D2055736572204D656E7520526567696F6E20506C7567696E0D0A2020204E616D6573706163653A2053485F555345525F4D454E550D0A2020203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_imp.g_varchar2_table(3) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D202A2F0D0A200D0A7661722053485F555345525F4D454E55203D202866756E6374696F6E202829207B0D0A202020202275736520737472696374223B0D0A20';
wwv_flow_imp.g_varchar2_table(4) := '0D0A202020202F2F20547261636B20696E697469616C697A656420777261707065722069647320736F20696E697428292063616E20736166656C792062652063616C6C6564206D6F72650D0A202020202F2F207468616E206F6E636520666F7220746865';
wwv_flow_imp.g_varchar2_table(5) := '2073616D6520726567696F6E2028652E672E20616674657220616E20416A617820726567696F6E2072656672657368292E0D0A2020202076617220696E697469616C697A6564203D207B7D3B0D0A200D0A2020202066756E6374696F6E2067657450616E';
wwv_flow_imp.g_varchar2_table(6) := '656C2877726170706572496429207B0D0A20202020202020207661722070616E656C4964203D202273682D756D2D70616E656C2D22202B207772617070657249642E7265706C616365282F5E73682D756D2D2F2C202222293B0D0A202020202020202072';
wwv_flow_imp.g_varchar2_table(7) := '657475726E20646F63756D656E742E676574456C656D656E74427949642870616E656C4964293B0D0A202020207D0D0A200D0A2020202066756E6374696F6E20706F736974696F6E50616E656C28747269676765722C2070616E656C2C20616C69676E29';
wwv_flow_imp.g_varchar2_table(8) := '207B0D0A20202020202020207661722072656374203D20747269676765722E676574426F756E64696E67436C69656E745265637428293B0D0A202020202020202076617220676170203D20363B0D0A200D0A202020202020202070616E656C2E7374796C';
wwv_flow_imp.g_varchar2_table(9) := '652E746F70203D2028726563742E626F74746F6D202B2067617029202B20227078223B0D0A200D0A202020202020202069662028616C69676E203D3D3D20224C4546542229207B0D0A20202020202020202020202070616E656C2E7374796C652E6C6566';
wwv_flow_imp.g_varchar2_table(10) := '74203D20726563742E6C656674202B20227078223B0D0A20202020202020202020202070616E656C2E7374796C652E7269676874203D20226175746F223B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020202070616E656C2E';
wwv_flow_imp.g_varchar2_table(11) := '7374796C652E6C656674203D20226175746F223B0D0A20202020202020202020202070616E656C2E7374796C652E7269676874203D202877696E646F772E696E6E65725769647468202D20726563742E726967687429202B20227078223B0D0A20202020';
wwv_flow_imp.g_varchar2_table(12) := '202020207D0D0A202020207D0D0A200D0A2020202066756E6374696F6E20696E69742877726170706572496429207B0D0A20202020202020207661722077726170706572203D20646F63756D656E742E676574456C656D656E7442794964287772617070';
wwv_flow_imp.g_varchar2_table(13) := '65724964293B0D0A202020202020202069662028217772617070657229207B0D0A20202020202020202020202072657475726E3B0D0A20202020202020207D0D0A200D0A20202020202020207661722074726967676572203D20777261707065722E7175';
wwv_flow_imp.g_varchar2_table(14) := '65727953656C6563746F7228222E73682D756D2D7472696767657222293B0D0A20202020202020207661722070616E656C203D2067657450616E656C28777261707065724964293B0D0A200D0A2020202020202020696620282174726967676572207C7C';
wwv_flow_imp.g_varchar2_table(15) := '202170616E656C29207B0D0A20202020202020202020202072657475726E3B0D0A20202020202020207D0D0A200D0A20202020202020202F2F20506F7274616C207061747465726E3A206D6F7665207468652070616E656C206F7574206F662074686520';
wwv_flow_imp.g_varchar2_table(16) := '6E617662617220736F20616E0D0A20202020202020202F2F20616E636573746F722773206F766572666C6F773A68696464656E2063616E206E6576657220636C69702069742E0D0A20202020202020206966202870616E656C2E706172656E744E6F6465';
wwv_flow_imp.g_varchar2_table(17) := '20213D3D20646F63756D656E742E626F647929207B0D0A202020202020202020202020646F63756D656E742E626F64792E617070656E644368696C642870616E656C293B0D0A20202020202020207D0D0A200D0A20202020202020202F2F2041766F6964';
wwv_flow_imp.g_varchar2_table(18) := '20646F75626C652D62696E64696E67206C697374656E65727320696620696E697428292072756E7320616761696E20666F72207468650D0A20202020202020202F2F2073616D6520777261707065722028652E672E206166746572206120706172746961';
wwv_flow_imp.g_varchar2_table(19) := '6C20706167652072656672657368292E0D0A202020202020202069662028696E697469616C697A65645B7772617070657249645D29207B0D0A20202020202020202020202072657475726E3B0D0A20202020202020207D0D0A2020202020202020696E69';
wwv_flow_imp.g_varchar2_table(20) := '7469616C697A65645B7772617070657249645D203D20747275653B0D0A200D0A202020202020202076617220616C69676E203D20777261707065722E6765744174747269627574652822646174612D756D2D616C69676E2229207C7C2022524947485422';
wwv_flow_imp.g_varchar2_table(21) := '3B0D0A2020202020202020766172206974656D73203D2041727261792E70726F746F747970652E736C6963652E63616C6C280D0A20202020202020202020202070616E656C2E717565727953656C6563746F72416C6C28222E73682D756D2D6974656D22';
wwv_flow_imp.g_varchar2_table(22) := '290D0A2020202020202020293B0D0A200D0A2F2F204B65657020696E2073796E6320776974682074686520435353202273682D756D2D70616E656C2D6F75742220616E696D6174696F6E2D6475726174696F6E2E0D0A76617220434C4F53455F414E494D';
wwv_flow_imp.g_varchar2_table(23) := '4154494F4E5F4D53203D203330303B0D0A76617220636C6F736546696E616C697A6554696D6572203D206E756C6C3B0D0A0D0A2F2F204F6E6C7920636C65617273207468652070656E64696E672074696D6572202D20646F6573204E4F5420746F756368';
wwv_flow_imp.g_varchar2_table(24) := '20746865202269732D636C6F73696E67220D0A2F2F20636C6173732E202852656D6F76696E672074686520636C61737320686572652077617320746865206275673A20636C6F736550616E656C28292063616C6C65640D0A2F2F20746869732072696768';
wwv_flow_imp.g_varchar2_table(25) := '7420616674657220616464696E67202269732D636C6F73696E67222C20696E7374616E746C7920737472697070696E67206974206261636B0D0A2F2F206F6666206265666F7265207468652062726F777365722065766572207061696E74656420612066';
wwv_flow_imp.g_varchar2_table(26) := '72616D65202D20736F2074686520636C6F73650D0A2F2F20616E696D6174696F6E206E65766572206861642061206368616E636520746F2072756E2E290D0A66756E6374696F6E20636C656172436C6F736554696D65722829207B0D0A20202020696620';
wwv_flow_imp.g_varchar2_table(27) := '28636C6F736546696E616C697A6554696D657229207B0D0A202020202020202077696E646F772E636C65617254696D656F757428636C6F736546696E616C697A6554696D6572293B0D0A2020202020202020636C6F736546696E616C697A6554696D6572';
wwv_flow_imp.g_varchar2_table(28) := '203D206E756C6C3B0D0A202020207D0D0A7D0D0A0D0A66756E6374696F6E206F70656E50616E656C2829207B0D0A202020202F2F2052656F70656E696E67206D69642D636C6F73653A2063616E63656C207468652070656E64696E672066696E616C697A';
wwv_flow_imp.g_varchar2_table(29) := '652074696D657220414E440D0A202020202F2F206578706C696369746C792064726F70202269732D636C6F73696E6722206865726520287468697320697320746865206F6E6520706C61636520746861740D0A202020202F2F2073686F756C642072656D';
wwv_flow_imp.g_varchar2_table(30) := '6F76652069742C2073696E63652077652772652061626F757420746F2073686F77207468652070616E656C206672657368292E0D0A20202020636C656172436C6F736554696D657228293B0D0A2020202070616E656C2E636C6173734C6973742E72656D';
wwv_flow_imp.g_varchar2_table(31) := '6F7665282269732D636C6F73696E6722293B0D0A20202020706F736974696F6E50616E656C28747269676765722C2070616E656C2C20616C69676E293B0D0A2020202070616E656C2E636C6173734C6973742E616464282269732D6F70656E22293B0D0A';
wwv_flow_imp.g_varchar2_table(32) := '2020202070616E656C2E7365744174747269627574652822617269612D68696464656E222C202266616C736522293B0D0A20202020747269676765722E7365744174747269627574652822617269612D657870616E646564222C20227472756522293B0D';
wwv_flow_imp.g_varchar2_table(33) := '0A20202020777261707065722E636C6173734C6973742E616464282269732D61637469766522293B0D0A7D0D0A0D0A66756E6374696F6E20636C6F736550616E656C2872657475726E466F63757329207B0D0A20202020696620282169734F70656E2829';
wwv_flow_imp.g_varchar2_table(34) := '29207B0D0A202020202020202072657475726E3B0D0A202020207D0D0A0D0A202020202F2F204F6E6C7920636C65617220612073747261792074696D65722068657265202D206E6576657220746F7563682074686520636C6173732C2073696E63650D0A';
wwv_flow_imp.g_varchar2_table(35) := '202020202F2F20776527726520616464696E67202269732D636C6F73696E67222062656C6F7720616E64206E65656420697420746F20737572766976652E0D0A20202020636C656172436C6F736554696D657228293B0D0A0D0A2020202070616E656C2E';
wwv_flow_imp.g_varchar2_table(36) := '636C6173734C6973742E72656D6F7665282269732D6F70656E22293B0D0A2020202070616E656C2E636C6173734C6973742E616464282269732D636C6F73696E6722293B0D0A2020202070616E656C2E7365744174747269627574652822617269612D68';
wwv_flow_imp.g_varchar2_table(37) := '696464656E222C20227472756522293B0D0A20202020747269676765722E7365744174747269627574652822617269612D657870616E646564222C202266616C736522293B0D0A20202020777261707065722E636C6173734C6973742E72656D6F766528';
wwv_flow_imp.g_varchar2_table(38) := '2269732D61637469766522293B0D0A0D0A20202020636C6F736546696E616C697A6554696D6572203D2077696E646F772E73657454696D656F75742866756E6374696F6E202829207B0D0A202020202020202070616E656C2E636C6173734C6973742E72';
wwv_flow_imp.g_varchar2_table(39) := '656D6F7665282269732D636C6F73696E6722293B0D0A2020202020202020636C6F736546696E616C697A6554696D6572203D206E756C6C3B0D0A20202020202020206966202872657475726E466F63757329207B0D0A2020202020202020202020207472';
wwv_flow_imp.g_varchar2_table(40) := '69676765722E666F63757328293B0D0A20202020202020207D0D0A202020207D2C20434C4F53455F414E494D4154494F4E5F4D53293B0D0A7D0D0A0D0A66756E6374696F6E2069734F70656E2829207B0D0A2020202072657475726E2070616E656C2E63';
wwv_flow_imp.g_varchar2_table(41) := '6C6173734C6973742E636F6E7461696E73282269732D6F70656E22293B0D0A7D0D0A200D0A202020202020202066756E6374696F6E20746F67676C6550616E656C286576656E7429207B0D0A2020202020202020202020206576656E742E73746F705072';
wwv_flow_imp.g_varchar2_table(42) := '6F7061676174696F6E28293B0D0A2020202020202020202020206966202869734F70656E282929207B0D0A20202020202020202020202020202020636C6F736550616E656C2866616C7365293B0D0A2020202020202020202020207D20656C7365207B0D';
wwv_flow_imp.g_varchar2_table(43) := '0A202020202020202020202020202020206F70656E50616E656C28293B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A200D0A202020202020202066756E6374696F6E2061637469766174654974656D286974656D29207B0D0A20';
wwv_flow_imp.g_varchar2_table(44) := '2020202020202020202020766172206C696E6B203D206974656D2E6765744174747269627574652822646174612D6C696E6B22293B0D0A202020202020202020202020636C6F736550616E656C2866616C7365293B0D0A20202020202020202020202069';
wwv_flow_imp.g_varchar2_table(45) := '6620286C696E6B29207B0D0A2020202020202020202020202020202077696E646F772E6C6F636174696F6E2E68726566203D206C696E6B3B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A200D0A202020202020202066756E6374';
wwv_flow_imp.g_varchar2_table(46) := '696F6E20666F6375734974656D28696E64657829207B0D0A202020202020202020202020696620286974656D732E6C656E677468203D3D3D203029207B0D0A2020202020202020202020202020202072657475726E3B0D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(47) := '7D0D0A20202020202020202020202076617220746172676574203D202828696E6465782025206974656D732E6C656E67746829202B206974656D732E6C656E677468292025206974656D732E6C656E6774683B0D0A202020202020202020202020697465';
wwv_flow_imp.g_varchar2_table(48) := '6D735B7461726765745D2E666F63757328293B0D0A20202020202020207D0D0A200D0A20202020202020202F2F202D2D205472696767657220696E746572616374696F6E202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(49) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A2020202020202020747269676765722E6164644576656E744C697374656E65722822636C69636B222C20746F67676C6550616E656C293B0D0A200D0A2020202020202020747269676765722E6164644576';
wwv_flow_imp.g_varchar2_table(50) := '656E744C697374656E657228226B6579646F776E222C2066756E6374696F6E20286576656E7429207B0D0A202020202020202020202020696620286576656E742E6B6579203D3D3D2022456E74657222207C7C206576656E742E6B6579203D3D3D202220';
wwv_flow_imp.g_varchar2_table(51) := '2229207B0D0A202020202020202020202020202020206576656E742E70726576656E7444656661756C7428293B0D0A20202020202020202020202020202020746F67676C6550616E656C286576656E74293B0D0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(52) := '6966202869734F70656E282929207B0D0A2020202020202020202020202020202020202020666F6375734974656D2830293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D20656C736520696620286576656E742E';
wwv_flow_imp.g_varchar2_table(53) := '6B6579203D3D3D20224172726F77446F776E22202626202169734F70656E282929207B0D0A202020202020202020202020202020206576656E742E70726576656E7444656661756C7428293B0D0A202020202020202020202020202020206F70656E5061';
wwv_flow_imp.g_varchar2_table(54) := '6E656C28293B0D0A20202020202020202020202020202020666F6375734974656D2830293B0D0A2020202020202020202020207D20656C736520696620286576656E742E6B6579203D3D3D20224573636170652229207B0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(55) := '2020202020636C6F736550616E656C2866616C7365293B0D0A2020202020202020202020207D0D0A20202020202020207D293B0D0A200D0A20202020202020202F2F202D2D204D656E75206974656D20696E746572616374696F6E202D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(56) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20202020202020206974656D732E666F72456163682866756E6374696F6E20286974656D2C20696E64657829207B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(57) := '20206974656D2E6164644576656E744C697374656E65722822636C69636B222C2066756E6374696F6E202829207B0D0A2020202020202020202020202020202061637469766174654974656D286974656D293B0D0A2020202020202020202020207D293B';
wwv_flow_imp.g_varchar2_table(58) := '0D0A200D0A2020202020202020202020206974656D2E6164644576656E744C697374656E657228226B6579646F776E222C2066756E6374696F6E20286576656E7429207B0D0A20202020202020202020202020202020696620286576656E742E6B657920';
wwv_flow_imp.g_varchar2_table(59) := '3D3D3D2022456E74657222207C7C206576656E742E6B6579203D3D3D2022202229207B0D0A20202020202020202020202020202020202020206576656E742E70726576656E7444656661756C7428293B0D0A202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(60) := '202061637469766174654974656D286974656D293B0D0A202020202020202020202020202020207D20656C736520696620286576656E742E6B6579203D3D3D20224172726F77446F776E2229207B0D0A2020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(61) := '6576656E742E70726576656E7444656661756C7428293B0D0A2020202020202020202020202020202020202020666F6375734974656D28696E646578202B2031293B0D0A202020202020202020202020202020207D20656C736520696620286576656E74';
wwv_flow_imp.g_varchar2_table(62) := '2E6B6579203D3D3D20224172726F7755702229207B0D0A20202020202020202020202020202020202020206576656E742E70726576656E7444656661756C7428293B0D0A2020202020202020202020202020202020202020666F6375734974656D28696E';
wwv_flow_imp.g_varchar2_table(63) := '646578202D2031293B0D0A202020202020202020202020202020207D20656C736520696620286576656E742E6B6579203D3D3D20224573636170652229207B0D0A2020202020202020202020202020202020202020636C6F736550616E656C2874727565';
wwv_flow_imp.g_varchar2_table(64) := '293B0D0A202020202020202020202020202020207D20656C736520696620286576656E742E6B6579203D3D3D20225461622229207B0D0A2020202020202020202020202020202020202020636C6F736550616E656C2866616C7365293B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(65) := '20202020202020202020207D0D0A2020202020202020202020207D293B0D0A20202020202020207D293B0D0A200D0A20202020202020202F2F202D2D20476C6F62616C20636C6F73652068616E646C657273202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_imp.g_varchar2_table(66) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A2020202020202020646F63756D656E742E6164644576656E744C697374656E65722822636C69636B222C2066756E6374696F6E20286576656E7429207B0D0A20202020';
wwv_flow_imp.g_varchar2_table(67) := '2020202020202020696620282169734F70656E282929207B0D0A2020202020202020202020202020202072657475726E3B0D0A2020202020202020202020207D0D0A202020202020202020202020696620282170616E656C2E636F6E7461696E73286576';
wwv_flow_imp.g_varchar2_table(68) := '656E742E746172676574292026262021747269676765722E636F6E7461696E73286576656E742E7461726765742929207B0D0A20202020202020202020202020202020636C6F736550616E656C2866616C7365293B0D0A2020202020202020202020207D';
wwv_flow_imp.g_varchar2_table(69) := '0D0A20202020202020207D293B0D0A200D0A2020202020202020646F63756D656E742E6164644576656E744C697374656E657228226B6579646F776E222C2066756E6374696F6E20286576656E7429207B0D0A2020202020202020202020206966202865';
wwv_flow_imp.g_varchar2_table(70) := '76656E742E6B6579203D3D3D2022457363617065222026262069734F70656E282929207B0D0A20202020202020202020202020202020636C6F736550616E656C2874727565293B0D0A2020202020202020202020207D0D0A20202020202020207D293B0D';
wwv_flow_imp.g_varchar2_table(71) := '0A200D0A202020202020202077696E646F772E6164644576656E744C697374656E65722822726573697A65222C2066756E6374696F6E202829207B0D0A2020202020202020202020206966202869734F70656E282929207B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(72) := '202020202020706F736974696F6E50616E656C28747269676765722C2070616E656C2C20616C69676E293B0D0A2020202020202020202020207D0D0A20202020202020207D293B0D0A200D0A202020202020202077696E646F772E6164644576656E744C';
wwv_flow_imp.g_varchar2_table(73) := '697374656E657228227363726F6C6C222C2066756E6374696F6E202829207B0D0A2020202020202020202020206966202869734F70656E282929207B0D0A20202020202020202020202020202020706F736974696F6E50616E656C28747269676765722C';
wwv_flow_imp.g_varchar2_table(74) := '2070616E656C2C20616C69676E293B0D0A2020202020202020202020207D0D0A20202020202020207D2C2074727565293B0D0A202020207D0D0A200D0A2020202072657475726E207B0D0A2020202020202020696E69743A20696E69740D0A202020207D';
wwv_flow_imp.g_varchar2_table(75) := '3B0D0A7D2928293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(111786191029507428)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_file_name=>'profile_bar.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '406B65796672616D65732073682D756D2D73776970652D696E7B30257B6F7061636974793A303B7472616E73666F726D3A7472616E736C61746558283630707829207363616C65282E3936297D746F7B6F7061636974793A313B7472616E73666F726D3A';
wwv_flow_imp.g_varchar2_table(2) := '7472616E736C61746558283029207363616C652831297D7D406B65796672616D65732073682D756D2D73776970652D6F75747B30257B6F7061636974793A313B7472616E73666F726D3A7472616E736C61746558283029207363616C652831297D746F7B';
wwv_flow_imp.g_varchar2_table(3) := '6F7061636974793A303B7472616E73666F726D3A7472616E736C61746558283630707829207363616C65282E3936297D7D406B65796672616D65732073682D756D2D70616E656C2D6F75747B30257B6F7061636974793A313B636C69702D706174683A63';
wwv_flow_imp.g_varchar2_table(4) := '6972636C6528313431256174203130302530293B7472616E73666F726D3A7363616C652831293B66696C7465723A626C75722830297D746F7B6F7061636974793A303B636C69702D706174683A636972636C652830206174203130302530293B7472616E';
wwv_flow_imp.g_varchar2_table(5) := '73666F726D3A7363616C65282E3932293B66696C7465723A626C757228367078297D7D2E73682D756D2D747269676765722C2E73682D756D2D777261707065727B646973706C61793A696E6C696E652D666C65783B616C69676E2D6974656D733A63656E';
wwv_flow_imp.g_varchar2_table(6) := '7465727D2E73682D756D2D777261707065727B706F736974696F6E3A72656C61746976653B6761703A3870787D2E73682D756D2D747269676765727B6761703A313070783B70616464696E673A347078203870783B626F726465722D7261646975733A38';
wwv_flow_imp.g_varchar2_table(7) := '70783B637572736F723A706F696E7465723B6F75746C696E653A303B7472616E736974696F6E3A6261636B67726F756E642D636F6C6F72202E31357320656173657D2E73682D756D2D747269676765723A686F7665722C2E73682D756D2D777261707065';
wwv_flow_imp.g_varchar2_table(8) := '722E69732D616374697665202E73682D756D2D747269676765727B6261636B67726F756E642D636F6C6F723A7267626128302C302C302C2E3034297D2E73682D756D2D747269676765723A666F6375732D76697369626C657B626F782D736861646F773A';
wwv_flow_imp.g_varchar2_table(9) := '30203020302032707820726762612835392C3133302C3234362C2E352921696D706F7274616E747D2E73682D756D2D6176617461727B706F736974696F6E3A72656C61746976653B666C65783A302030206175746F3B646973706C61793A696E6C696E65';
wwv_flow_imp.g_varchar2_table(10) := '2D666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A63656E7465723B6F766572666C6F773A68696464656E3B6261636B67726F756E642D636F6C6F723A236535653765623B626F726465723A31707820';
wwv_flow_imp.g_varchar2_table(11) := '736F6C6964207472616E73706172656E743B626F782D73697A696E673A626F726465722D626F787D2E73682D756D2D6176617461722D2D726F756E647B626F726465722D7261646975733A35302521696D706F7274616E747D2E73682D756D2D61766174';
wwv_flow_imp.g_varchar2_table(12) := '61722D2D7371756172657B626F726465722D7261646975733A3021696D706F7274616E747D2E73682D756D2D6176617461722D2D726F756E6465647B626F726465722D7261646975733A38707821696D706F7274616E747D2E73682D756D2D6176617461';
wwv_flow_imp.g_varchar2_table(13) := '722D696D677B77696474683A313030253B6865696768743A313030253B6F626A6563742D6669743A636F7665723B646973706C61793A626C6F636B7D2E73682D756D2D6176617461722D696E697469616C737B666F6E742D73697A653A313370783B666F';
wwv_flow_imp.g_varchar2_table(14) := '6E742D7765696768743A3630303B636F6C6F723A233462353536333B6C696E652D6865696768743A313B757365722D73656C6563743A6E6F6E657D2E73682D756D2D7374617475732D646F747B706F736974696F6E3A6162736F6C7574653B626F74746F';
wwv_flow_imp.g_varchar2_table(15) := '6D3A2D3170783B72696768743A2D3170783B77696474683A313070783B6865696768743A313070783B626F726465722D7261646975733A35302521696D706F7274616E743B626F726465723A32707820736F6C696420236666663B626F782D73697A696E';
wwv_flow_imp.g_varchar2_table(16) := '673A636F6E74656E742D626F787D2E73682D756D2D746578747B646973706C61793A666C65783B666C65782D646972656374696F6E3A636F6C756D6E3B6C696E652D6865696768743A312E32353B746578742D616C69676E3A6C6566743B77686974652D';
wwv_flow_imp.g_varchar2_table(17) := '73706163653A6E6F777261707D2E73682D756D2D6E616D657B666F6E742D73697A653A313370783B666F6E742D7765696768743A3630303B636F6C6F723A766172282D2D73682D756D2D6E616D652D636F6C6F722C2023464646464646297D2E73682D75';
wwv_flow_imp.g_varchar2_table(18) := '6D2D656D61696C7B666F6E742D73697A653A313270783B636F6C6F723A766172282D2D73682D756D2D656D61696C2D636F6C6F722C2023464646464646297D2E73682D756D2D63686576726F6E7B666C65783A302030206175746F3B77696474683A3870';
wwv_flow_imp.g_varchar2_table(19) := '783B6865696768743A3870783B626F726465722D72696768743A312E35707820736F6C696420236666663B626F726465722D626F74746F6D3A312E35707820736F6C696420236666663B7472616E73666F726D3A726F74617465283435646567293B6D61';
wwv_flow_imp.g_varchar2_table(20) := '7267696E2D746F703A2D3370783B7472616E736974696F6E3A7472616E73666F726D202E31357320656173657D2E73682D756D2D777261707065722E69732D616374697665202E73682D756D2D63686576726F6E7B7472616E73666F726D3A726F746174';
wwv_flow_imp.g_varchar2_table(21) := '6528323235646567293B6D617267696E2D746F703A3370787D2E73682D756D2D6C6F676F75742D6F7574736964657B646973706C61793A696E6C696E652D666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E';
wwv_flow_imp.g_varchar2_table(22) := '743A63656E7465723B626F782D73697A696E673A626F726465722D626F783B636F6C6F723A236666663B746578742D6465636F726174696F6E3A6E6F6E653B666C65783A302030206175746F3B626F726465723A312E35707820736F6C6964207472616E';
wwv_flow_imp.g_varchar2_table(23) := '73706172656E743B7472616E736974696F6E3A6261636B67726F756E642D636F6C6F72202E31357320656173652C636F6C6F72202E31357320656173652C626F726465722D636F6C6F72202E31357320656173657D2E73682D756D2D6C6F676F75742D6F';
wwv_flow_imp.g_varchar2_table(24) := '7574736964652D746578747B666F6E742D73697A653A313370783B666F6E742D7765696768743A3630303B77686974652D73706163653A6E6F777261707D2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65317B77696474683A3332';
wwv_flow_imp.g_varchar2_table(25) := '70783B6865696768743A333270783B626F726465722D7261646975733A3870787D2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65313A686F7665727B6261636B67726F756E642D636F6C6F723A236666663B636F6C6F723A233761';
wwv_flow_imp.g_varchar2_table(26) := '323934313B626F782D736861646F773A302032707820367078207267626128302C302C302C2E3138297D2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65327B77696474683A333370783B6865696768743A333370783B626F726465';
wwv_flow_imp.g_varchar2_table(27) := '722D7261646975733A35302521696D706F7274616E743B626F726465722D636F6C6F723A236666667D2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65323A686F7665727B626F726465722D636F6C6F723A236666667D2E73682D75';
wwv_flow_imp.g_varchar2_table(28) := '6D2D6C6F676F75742D6F7574736964652D2D7374796C65332C2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65347B6865696768743A333270783B70616464696E673A3020313270783B626F726465722D7261646975733A3870783B';
wwv_flow_imp.g_varchar2_table(29) := '6761703A3670787D2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65323A686F7665722C2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65333A686F7665727B6261636B67726F756E642D636F6C6F723A236666';
wwv_flow_imp.g_varchar2_table(30) := '663B636F6C6F723A233761323934313B626F782D736861646F773A302032707820367078207267626128302C302C302C2E3138297D2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65347B70616464696E673A3020313470783B6261';
wwv_flow_imp.g_varchar2_table(31) := '636B67726F756E642D636F6C6F723A236463323632363B626F726465722D636F6C6F723A236463323632363B636F6C6F723A236666667D2E73682D756D2D6C6F676F75742D6F7574736964652D2D7374796C65343A686F7665727B6261636B67726F756E';
wwv_flow_imp.g_varchar2_table(32) := '642D636F6C6F723A236239316331633B626F726465722D636F6C6F723A236239316331633B636F6C6F723A236666667D2E73682D756D2D70616E656C7B646973706C61793A6E6F6E653B706F736974696F6E3A66697865643B7A2D696E6465783A393939';
wwv_flow_imp.g_varchar2_table(33) := '393B77696474683A6D61782D636F6E74656E743B6D696E2D77696474683A31383070783B6D61782D77696474683A33363070783B6261636B67726F756E642D636F6C6F723A766172282D2D73682D756D2D70616E656C2D62672C2023464646464646293B';
wwv_flow_imp.g_varchar2_table(34) := '626F726465723A31707820736F6C6964207267626128302C302C302C2E3038293B626F726465722D7261646975733A313070783B626F782D736861646F773A30203870782032347078207267626128302C302C302C2E3132292C30203270782036707820';
wwv_flow_imp.g_varchar2_table(35) := '7267626128302C302C302C2E3038293B70616464696E673A3670783B626F782D73697A696E673A626F726465722D626F787D2E73682D756D2D70616E656C2E69732D6F70656E7B646973706C61793A626C6F636B3B616E696D6174696F6E3A73682D756D';
wwv_flow_imp.g_varchar2_table(36) := '2D73776970652D696E202E35732063756269632D62657A696572282E33342C312E342C2E36342C312920626F74687D2E73682D756D2D70616E656C2E69732D636C6F73696E677B646973706C61793A626C6F636B3B616E696D6174696F6E3A73682D756D';
wwv_flow_imp.g_varchar2_table(37) := '2D73776970652D6F7574202E33732063756269632D62657A696572282E342C302C312C312920626F74683B706F696E7465722D6576656E74733A6E6F6E657D2E73682D756D2D70616E656C2D6974656D737B646973706C61793A666C65783B666C65782D';
wwv_flow_imp.g_varchar2_table(38) := '646972656374696F6E3A636F6C756D6E7D2E73682D756D2D6974656D7B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465723B6761703A313070783B70616464696E673A38707820313070783B626F726465722D726164697573';
wwv_flow_imp.g_varchar2_table(39) := '3A3670783B637572736F723A706F696E7465723B636F6C6F723A766172282D2D73682D756D2D70616E656C2D746578742C2023313131383237293B666F6E742D73697A653A313370783B6F75746C696E653A307D2E73682D756D2D6974656D2D2D737562';
wwv_flow_imp.g_varchar2_table(40) := '7B70616464696E672D6C6566743A333070787D2E73682D756D2D6974656D3A666F6375732D76697369626C652C2E73682D756D2D6974656D3A686F7665727B6261636B67726F756E642D636F6C6F723A766172282D2D73682D756D2D70616E656C2D686F';
wwv_flow_imp.g_varchar2_table(41) := '7665722C2023463346344636293B636F6C6F723A236666667D2E73682D756D2D6974656D2D69636F6E7B646973706C61793A696E6C696E652D666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A63656E';
wwv_flow_imp.g_varchar2_table(42) := '7465723B77696474683A313870783B666C65783A302030206175746F3B636F6C6F723A696E68657269743B6F7061636974793A2E37357D2E73682D756D2D6974656D2D69636F6E2D746578747B646973706C61793A696E6C696E652D626C6F636B3B666F';
wwv_flow_imp.g_varchar2_table(43) := '6E742D73697A653A313470783B6C696E652D6865696768743A313B666F6E742D7374796C653A6E6F726D616C7D2E73682D756D2D6974656D2D746578747B666C65783A312031206175746F3B77686974652D73706163653A6E6F777261703B6F76657266';
wwv_flow_imp.g_varchar2_table(44) := '6C6F773A68696464656E3B746578742D6F766572666C6F773A656C6C69707369737D2E73682D756D2D736570617261746F727B6865696768743A3170783B6D617267696E3A367078203470783B6261636B67726F756E642D636F6C6F723A726762612830';
wwv_flow_imp.g_varchar2_table(45) := '2C302C302C2E3038297D2E73682D756D2D6974656D2D2D6C6F676F75747B636F6C6F723A236463323632367D2E73682D756D2D6974656D2D2D6C6F676F75743A666F6375732D76697369626C652C2E73682D756D2D6974656D2D2D6C6F676F75743A686F';
wwv_flow_imp.g_varchar2_table(46) := '7665727B6261636B67726F756E642D636F6C6F723A72676261283232302C33382C33382C2E3038293B636F6C6F723A236463323632367D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(114539226973845807)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_file_name=>'profile_bar.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '7661722053485F555345525F4D454E553D66756E6374696F6E28297B2275736520737472696374223B76617220653D7B7D3B66756E6374696F6E207428652C742C6E297B76617220693D652E676574426F756E64696E67436C69656E745265637428293B';
wwv_flow_imp.g_varchar2_table(2) := '742E7374796C652E746F703D692E626F74746F6D2B362B227078222C224C454654223D3D3D6E3F28742E7374796C652E6C6566743D692E6C6566742B227078222C742E7374796C652E72696768743D226175746F22293A28742E7374796C652E6C656674';
wwv_flow_imp.g_varchar2_table(3) := '3D226175746F222C742E7374796C652E72696768743D77696E646F772E696E6E657257696474682D692E72696768742B22707822297D72657475726E7B696E69743A66756E6374696F6E286E297B76617220693D646F63756D656E742E676574456C656D';
wwv_flow_imp.g_varchar2_table(4) := '656E7442794964286E293B69662869297B766172206F3D692E717565727953656C6563746F7228222E73682D756D2D7472696767657222292C723D66756E6374696F6E2865297B76617220743D2273682D756D2D70616E656C2D222B652E7265706C6163';
wwv_flow_imp.g_varchar2_table(5) := '65282F5E73682D756D2D2F2C2222293B72657475726E20646F63756D656E742E676574456C656D656E74427949642874297D286E293B6966286F262672262628722E706172656E744E6F6465213D3D646F63756D656E742E626F64792626646F63756D65';
wwv_flow_imp.g_varchar2_table(6) := '6E742E626F64792E617070656E644368696C642872292C21655B6E5D29297B655B6E5D3D21303B76617220613D692E6765744174747269627574652822646174612D756D2D616C69676E22297C7C225249474854222C733D41727261792E70726F746F74';
wwv_flow_imp.g_varchar2_table(7) := '7970652E736C6963652E63616C6C28722E717565727953656C6563746F72416C6C28222E73682D756D2D6974656D2229292C633D3330302C753D6E756C6C3B6F2E6164644576656E744C697374656E65722822636C69636B222C70292C6F2E6164644576';
wwv_flow_imp.g_varchar2_table(8) := '656E744C697374656E657228226B6579646F776E222C2866756E6374696F6E2865297B22456E746572223D3D3D652E6B65797C7C2220223D3D3D652E6B65793F28652E70726576656E7444656661756C7428292C702865292C762829262667283029293A';
wwv_flow_imp.g_varchar2_table(9) := '224172726F77446F776E22213D3D652E6B65797C7C7628293F22457363617065223D3D3D652E6B6579262666282131293A28652E70726576656E7444656661756C7428292C6428292C67283029297D29292C732E666F7245616368282866756E6374696F';
wwv_flow_imp.g_varchar2_table(10) := '6E28652C74297B652E6164644576656E744C697374656E65722822636C69636B222C2866756E6374696F6E28297B792865297D29292C652E6164644576656E744C697374656E657228226B6579646F776E222C2866756E6374696F6E286E297B22456E74';
wwv_flow_imp.g_varchar2_table(11) := '6572223D3D3D6E2E6B65797C7C2220223D3D3D6E2E6B65793F286E2E70726576656E7444656661756C7428292C79286529293A224172726F77446F776E223D3D3D6E2E6B65793F286E2E70726576656E7444656661756C7428292C6728742B3129293A22';
wwv_flow_imp.g_varchar2_table(12) := '4172726F775570223D3D3D6E2E6B65793F286E2E70726576656E7444656661756C7428292C6728742D3129293A22457363617065223D3D3D6E2E6B65793F66282130293A22546162223D3D3D6E2E6B6579262666282131297D29297D29292C646F63756D';
wwv_flow_imp.g_varchar2_table(13) := '656E742E6164644576656E744C697374656E65722822636C69636B222C2866756E6374696F6E2865297B762829262628722E636F6E7461696E7328652E746172676574297C7C6F2E636F6E7461696E7328652E746172676574297C7C6628213129297D29';
wwv_flow_imp.g_varchar2_table(14) := '292C646F63756D656E742E6164644576656E744C697374656E657228226B6579646F776E222C2866756E6374696F6E2865297B22457363617065223D3D3D652E6B65792626762829262666282130297D29292C77696E646F772E6164644576656E744C69';
wwv_flow_imp.g_varchar2_table(15) := '7374656E65722822726573697A65222C2866756E6374696F6E28297B762829262674286F2C722C61297D29292C77696E646F772E6164644576656E744C697374656E657228227363726F6C6C222C2866756E6374696F6E28297B762829262674286F2C72';
wwv_flow_imp.g_varchar2_table(16) := '2C61297D292C2130297D7D66756E6374696F6E206C28297B7526262877696E646F772E636C65617254696D656F75742875292C753D6E756C6C297D66756E6374696F6E206428297B6C28292C722E636C6173734C6973742E72656D6F7665282269732D63';
wwv_flow_imp.g_varchar2_table(17) := '6C6F73696E6722292C74286F2C722C61292C722E636C6173734C6973742E616464282269732D6F70656E22292C722E7365744174747269627574652822617269612D68696464656E222C2266616C736522292C6F2E736574417474726962757465282261';
wwv_flow_imp.g_varchar2_table(18) := '7269612D657870616E646564222C227472756522292C692E636C6173734C6973742E616464282269732D61637469766522297D66756E6374696F6E20662865297B7628292626286C28292C722E636C6173734C6973742E72656D6F7665282269732D6F70';
wwv_flow_imp.g_varchar2_table(19) := '656E22292C722E636C6173734C6973742E616464282269732D636C6F73696E6722292C722E7365744174747269627574652822617269612D68696464656E222C227472756522292C6F2E7365744174747269627574652822617269612D657870616E6465';
wwv_flow_imp.g_varchar2_table(20) := '64222C2266616C736522292C692E636C6173734C6973742E72656D6F7665282269732D61637469766522292C753D77696E646F772E73657454696D656F7574282866756E6374696F6E28297B722E636C6173734C6973742E72656D6F7665282269732D63';
wwv_flow_imp.g_varchar2_table(21) := '6C6F73696E6722292C753D6E756C6C2C6526266F2E666F63757328297D292C6329297D66756E6374696F6E207628297B72657475726E20722E636C6173734C6973742E636F6E7461696E73282269732D6F70656E22297D66756E6374696F6E2070286529';
wwv_flow_imp.g_varchar2_table(22) := '7B652E73746F7050726F7061676174696F6E28292C7628293F66282131293A6428297D66756E6374696F6E20792865297B76617220743D652E6765744174747269627574652822646174612D6C696E6B22293B66282131292C7426262877696E646F772E';
wwv_flow_imp.g_varchar2_table(23) := '6C6F636174696F6E2E687265663D74297D66756E6374696F6E20672865297B69662830213D3D732E6C656E677468297B76617220743D286525732E6C656E6774682B732E6C656E6774682925732E6C656E6774683B735B745D2E666F63757328297D7D7D';
wwv_flow_imp.g_varchar2_table(24) := '7D7D28293B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(114540443008844556)
,p_plugin_id=>wwv_flow_imp.id(111771349264624580)
,p_file_name=>'profile_bar.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
