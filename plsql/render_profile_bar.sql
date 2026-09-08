------------------------------------------------------------------------
-- S&H Software Solutions - User Menu Region Plugin
-- ------------------------------------------------------------------
-- Component : Render Function ("PL/SQL Code" - Component Definition ->
--             Callbacks -> Render Function Type = PL/SQL Code)
-- Version   : 1.2.0 (NEW: Logout Style attribute (attribute_24) - four
--             static values STYLE1..STYLE4 controlling the visual
--             appearance of the OUTSIDE logout button only. CSS-only
--             variants, no JS changes required.)
-- Date      : 2026-09-04
-- Author    : S&H Software Solutions
-- License   : MIT License. This code is free and open to use, modify,
--             and redistribute, with or without attribution, for
--             personal or commercial projects.
-- ------------------------------------------------------------------
-- NOTE: attribute_20 (Width) and attribute_21 (Alignment) are no
-- longer read at all - safe to delete both from the plugin's Custom
-- Attributes if you haven't already.
------------------------------------------------------------------------

FUNCTION render (
    p_region              IN apex_plugin.t_region,
    p_plugin              IN apex_plugin.t_plugin,
    p_is_printer_friendly IN BOOLEAN
) RETURN apex_plugin.t_region_render_result
IS
    -- Above this size, a DB-driven profile image is skipped (falls
    -- back to initials) rather than being embedded as Base64.
    c_max_image_bytes CONSTANT INTEGER := 307200; -- 300 KB

    ------------------------------------------------------------------
    -- Attribute values, read positionally
    ------------------------------------------------------------------
    v_show_image          VARCHAR2(4)    := p_region.attribute_01;
    v_image_source_attr   VARCHAR2(4000) := p_region.attribute_02;
    v_image_shape         VARCHAR2(20)   := NVL(p_region.attribute_03, 'ROUND');
    v_image_size_attr     VARCHAR2(10)   := p_region.attribute_04;
    v_image_border_color  VARCHAR2(20)   := p_region.attribute_05;
    v_first_name_attr     VARCHAR2(2000) := p_region.attribute_06;
    v_email_attr          VARCHAR2(4000) := p_region.attribute_07;
    v_show_status          VARCHAR2(4)   := p_region.attribute_08;
    v_status_color_attr   VARCHAR2(20)   := p_region.attribute_09;
    v_show_logout         VARCHAR2(4)    := NVL(p_region.attribute_10, 'Y');
    v_logout_link_attr    VARCHAR2(4000) := p_region.attribute_11;
    v_logout_icon_raw     VARCHAR2(200)  := NVL(p_region.attribute_12, 'fa-right-from-bracket');
    v_logout_position     VARCHAR2(20)   := NVL(TRIM(p_region.attribute_13), 'OUTSIDE');
    v_show_dropdown       VARCHAR2(4)    := NVL(p_region.attribute_14, 'Y');
    v_dropdown_query      CLOB           := p_region.attribute_15;
    v_show_chevron        VARCHAR2(4)    := NVL(p_region.attribute_16, 'Y');
    v_dropdown_bg_attr    VARCHAR2(20)   := p_region.attribute_17;
    v_dropdown_hover_attr VARCHAR2(20)   := p_region.attribute_18;
    v_dropdown_text_attr  VARCHAR2(20)   := p_region.attribute_19;
    -- attribute_20 (Width) and attribute_21 (Alignment) intentionally
    -- not read anymore - see header comment.
    v_last_name_attr      VARCHAR2(2000) := p_region.attribute_22;
    v_image_mime_attr     VARCHAR2(4000) := p_region.attribute_23;
    -- NEW: Logout Style - static LOV (STYLE1/STYLE2/STYLE3/STYLE4).
    -- Controls the OUTSIDE logout button's visual variant via CSS
    -- class only; validated/defaulted in the executable section below.
    v_logout_style        VARCHAR2(20)   := NVL(UPPER(TRIM(p_region.attribute_24)), 'STYLE1');

    ------------------------------------------------------------------
    -- Resolved/derived values
    ------------------------------------------------------------------
    v_user_first_name VARCHAR2(4000);
    v_user_last_name  VARCHAR2(4000);
    v_user_name       VARCHAR2(4000);
    v_user_email      VARCHAR2(4000);

    v_app_user VARCHAR2(4000);

    v_email_is_db BOOLEAN;
    v_e_table VARCHAR2(128);
    v_e_match VARCHAR2(128);
    v_e_value VARCHAR2(128);

    v_image_is_db    BOOLEAN;
    v_img_table      VARCHAR2(128);
    v_img_match      VARCHAR2(128);
    v_img_value      VARCHAR2(128);
    v_mime_table     VARCHAR2(128);
    v_mime_match     VARCHAR2(128);
    v_mime_value     VARCHAR2(128);
    v_image_blob     BLOB;
    v_image_mime     VARCHAR2(200);
    v_image_base64   CLOB;
    v_image_data_uri CLOB;
    v_image_src      VARCHAR2(4000);

    v_static_id  VARCHAR2(200);
    v_wrapper_id VARCHAR2(200);
    v_panel_id   VARCHAR2(200);

    v_html       CLOB;
    v_items_html CLOB;

    -- Dropdown data, fetched positionally: icon / text / link / menu_type
    TYPE t_vc_tab IS TABLE OF VARCHAR2(4000);
    v_text_tab t_vc_tab := t_vc_tab();
    v_link_tab t_vc_tab := t_vc_tab();
    v_type_tab t_vc_tab := t_vc_tab();
    v_icons    t_vc_tab := t_vc_tab();

    v_is_outside_logout BOOLEAN;
    v_is_inside_logout  BOOLEAN;

    v_result apex_plugin.t_region_render_result;

    ------------------------------------------------------------------
    -- Nested helpers - ALL after every variable above (PL/SQL rule: no
    -- variable declaration may follow a subprogram declaration in the
    -- same declare section).
    ------------------------------------------------------------------

    FUNCTION f_number (
        pi_value   IN VARCHAR2,
        pi_default IN NUMBER
    ) RETURN NUMBER
    IS
        v_num NUMBER;
    BEGIN
        v_num := TO_NUMBER(pi_value);
        IF v_num IS NULL OR v_num <= 0 THEN
            RETURN pi_default;
        END IF;
        RETURN v_num;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN pi_default;
    END f_number;

    FUNCTION f_color (
        pi_color   IN VARCHAR2,
        pi_default IN VARCHAR2
    ) RETURN VARCHAR2
    IS
    BEGIN
        IF pi_color IS NOT NULL
           AND REGEXP_LIKE(pi_color, '^#[0-9A-Fa-f]{3}([0-9A-Fa-f]{3})?$')
        THEN
            RETURN pi_color;
        END IF;
        RETURN pi_default;
    END f_color;

    FUNCTION f_icon_class (
        pi_icon IN VARCHAR2
    ) RETURN VARCHAR2
    IS
    BEGIN
        IF pi_icon IS NULL THEN
            RETURN NULL;
        END IF;
        IF pi_icon LIKE 'fa-%' THEN
            RETURN 'fa ' || pi_icon;
        END IF;
        RETURN pi_icon;
    END f_icon_class;

    FUNCTION f_initials (
        pi_name IN VARCHAR2
    ) RETURN VARCHAR2
    IS
        v_parts  apex_t_varchar2;
        v_result VARCHAR2(10) := '';
    BEGIN
        IF pi_name IS NULL OR TRIM(pi_name) IS NULL THEN
            RETURN '?';
        END IF;

        v_parts := apex_string.split(TRIM(pi_name), ' ');

        FOR i IN 1 .. LEAST(v_parts.COUNT, 2) LOOP
            IF LENGTH(v_parts(i)) > 0 THEN
                v_result := v_result || UPPER(SUBSTR(v_parts(i), 1, 1));
            END IF;
        END LOOP;

        RETURN NVL(NULLIF(v_result, ''), '?');
    END f_initials;

    ------------------------------------------------------------------
    -- Detects a "TABLE.MATCH_COLUMN.VALUE_COLUMN" reference (e.g.
    -- "SUPER_ADMIN.SUAD_EMAIL.SUAD_FIRST_NAME"). Returns TRUE and sets
    -- the OUT params when it matches; FALSE for anything else, so
    -- callers fall back to legacy literal-text behavior.
    ------------------------------------------------------------------
    FUNCTION f_parse_table_match_value (
        pi_ref    IN  VARCHAR2,
        po_table  OUT VARCHAR2,
        po_match  OUT VARCHAR2,
        po_value  OUT VARCHAR2
    ) RETURN BOOLEAN
    IS
        v_parts apex_t_varchar2;
    BEGIN
        po_table := NULL;
        po_match := NULL;
        po_value := NULL;

        IF pi_ref IS NULL THEN
            RETURN FALSE;
        END IF;

        IF REGEXP_LIKE(
               pi_ref,
               '^[A-Za-z_][A-Za-z0-9_$#]*\.[A-Za-z_][A-Za-z0-9_$#]*\.[A-Za-z_][A-Za-z0-9_$#]*$'
           )
        THEN
            v_parts  := apex_string.split(pi_ref, '.');
            po_table := UPPER(v_parts(1));
            po_match := UPPER(v_parts(2));
            po_value := UPPER(v_parts(3));
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END f_parse_table_match_value;

    FUNCTION f_lookup_value (
        pi_table    IN VARCHAR2,
        pi_match    IN VARCHAR2,
        pi_value    IN VARCHAR2,
        pi_app_user IN VARCHAR2
    ) RETURN VARCHAR2
    IS
        v_result VARCHAR2(4000);
        v_sql    VARCHAR2(4000);
    BEGIN
        v_sql := 'SELECT ' || pi_value ||
                 ' FROM '  || pi_table ||
                 ' WHERE UPPER(' || pi_match || ') = UPPER(:b1)';

        BEGIN
            EXECUTE IMMEDIATE v_sql INTO v_result USING pi_app_user;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_result := NULL;
            WHEN OTHERS THEN
                apex_debug.error(
                    p_message => 'SH_USER_MENU: F_LOOKUP_VALUE lookup failed for %s.%s - %s',
                    p0        => pi_table,
                    p1        => pi_value,
                    p2        => SQLERRM
                );
                v_result := NULL;
        END;

        RETURN v_result;
    END f_lookup_value;

    FUNCTION f_lookup_blob (
        pi_table    IN VARCHAR2,
        pi_match    IN VARCHAR2,
        pi_value    IN VARCHAR2,
        pi_app_user IN VARCHAR2
    ) RETURN BLOB
    IS
        v_result BLOB;
        v_sql    VARCHAR2(4000);
    BEGIN
        v_sql := 'SELECT ' || pi_value ||
                 ' FROM '  || pi_table ||
                 ' WHERE UPPER(' || pi_match || ') = UPPER(:b1)';

        BEGIN
            EXECUTE IMMEDIATE v_sql INTO v_result USING pi_app_user;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_result := NULL;
            WHEN OTHERS THEN
                apex_debug.error(
                    p_message => 'SH_USER_MENU: F_LOOKUP_BLOB lookup failed for %s.%s - %s',
                    p0        => pi_table,
                    p1        => pi_value,
                    p2        => SQLERRM
                );
                v_result := NULL;
        END;

        RETURN v_result;
    END f_lookup_blob;

    ------------------------------------------------------------------
    -- Resolves a DB-driven text attribute (First Name / Last Name). If
    -- pi_attr is TABLE.MATCH.VALUE, runs the lookup; otherwise returns
    -- pi_attr unchanged (legacy literal text / &ITEM. string).
    ------------------------------------------------------------------
    FUNCTION f_resolve_text (
        pi_attr     IN VARCHAR2,
        pi_app_user IN VARCHAR2
    ) RETURN VARCHAR2
    IS
        v_table VARCHAR2(128);
        v_match VARCHAR2(128);
        v_value VARCHAR2(128);
    BEGIN
        IF f_parse_table_match_value(pi_attr, v_table, v_match, v_value) THEN
            RETURN f_lookup_value(v_table, v_match, v_value, pi_app_user);
        END IF;
        RETURN pi_attr;
    END f_resolve_text;

    ------------------------------------------------------------------
    -- Splits an icon value on "|" into the icon itself and an optional
    -- hex color: "fa-star|#F59E0B" -> po_value='fa-star',
    -- po_color='#F59E0B". No "|" present -> po_value=pi_raw, po_color
    -- stays NULL (inherits the default color from CSS). An invalid
    -- color after "|" is silently dropped (f_color validates it) -
    -- falls back to inherited color, no error, no broken markup.
    ------------------------------------------------------------------
    PROCEDURE p_parse_icon (
        pi_raw   IN  VARCHAR2,
        po_value OUT VARCHAR2,
        po_color OUT VARCHAR2
    )
    IS
        v_sep_pos PLS_INTEGER;
    BEGIN
        po_value := pi_raw;
        po_color := NULL;

        IF pi_raw IS NULL THEN
            RETURN;
        END IF;

        v_sep_pos := INSTR(pi_raw, '|');
        IF v_sep_pos > 0 THEN
            po_value := SUBSTR(pi_raw, 1, v_sep_pos - 1);
            po_color := f_color(SUBSTR(pi_raw, v_sep_pos + 1), NULL);
        END IF;
    END p_parse_icon;

    ------------------------------------------------------------------
    -- Renders ONE icon's markup - shared by the dropdown item loop AND
    -- the Logout icon (inside or outside), so both accept the same
    -- "icon_value" / "icon_value|#hexcolor" convention. Branches on
    -- whether the icon part looks like a Font Awesome shorthand
    -- ("fa-...") or is plain text/emoji ("💬", "€", a single letter) -
    -- the latter is rendered as literal text content instead of an
    -- icon-font CSS class, since a random emoji obviously isn't a
    -- valid class name.
    ------------------------------------------------------------------
    FUNCTION f_render_icon_span (
        pi_raw IN VARCHAR2
    ) RETURN VARCHAR2
    IS
        v_value VARCHAR2(200);
        v_color VARCHAR2(20);
        v_style VARCHAR2(100);
    BEGIN
        p_parse_icon(pi_raw, v_value, v_color);

        IF v_value IS NULL THEN
            RETURN NULL;
        END IF;

        IF v_color IS NOT NULL THEN
            v_style := ' style="color:' || v_color || '"';
        END IF;

        IF v_value LIKE 'fa-%' THEN
            RETURN '<span class="' ||
                apex_escape.html_attribute(f_icon_class(v_value)) || '"' ||
                v_style || ' aria-hidden="true"></span>';
        END IF;

        RETURN '<span class="sh-um-item-icon-text"' || v_style ||
            ' aria-hidden="true">' || apex_escape.html(v_value) || '</span>';
    END f_render_icon_span;

    ------------------------------------------------------------------
    -- Bilingual DE/EN text, mirroring the same txt() convention used
    -- client-side in the other S&H plugins (there: navigator.language;
    -- here: V('BROWSER_LANGUAGE'), APEX's server-side equivalent of the
    -- browser's Accept-Language header). Used for the plugin's own
    -- fixed UI strings ("Sign Out", the trigger's aria-label) - NOT for
    -- developer-supplied content like dropdown item text, which stays
    -- exactly as configured.
    ------------------------------------------------------------------
    FUNCTION f_txt (
        pi_de IN VARCHAR2,
        pi_en IN VARCHAR2
    ) RETURN VARCHAR2
    IS
    BEGIN
        IF NVL(V('BROWSER_LANGUAGE'), 'en') LIKE 'de%' THEN
            RETURN pi_de;
        END IF;
        RETURN pi_en;
    END f_txt;

    ------------------------------------------------------------------
    -- Prints a CLOB via htp.prn in safely-sized chunks. htp.p/htp.prn
    -- only accept VARCHAR2, capped at 32767 BYTES (not characters).
    -- 8000 characters * up to 4 bytes/char (AL32UTF8 worst case) stays
    -- safely under that byte ceiling regardless of how many
    -- multi-byte characters land in any given chunk.
    ------------------------------------------------------------------
    PROCEDURE p_print_clob (
        pi_clob IN CLOB
    )
    IS
        v_len INTEGER;
        v_pos INTEGER := 1;
        v_amt CONSTANT PLS_INTEGER := 8000;
    BEGIN
        IF pi_clob IS NULL THEN
            RETURN;
        END IF;

        v_len := DBMS_LOB.GETLENGTH(pi_clob);

        WHILE v_pos <= v_len LOOP
            htp.prn(DBMS_LOB.SUBSTR(pi_clob, v_amt, v_pos));
            v_pos := v_pos + v_amt;
        END LOOP;
    END p_print_clob;
BEGIN
    v_app_user := V('APP_USER');

    -- NEW: Logout Style must be one of the 4 static LOV values coming
    -- from attribute_24, else silently fall back to STYLE1 (defensive
    -- against blank/garbage values, same pattern as other attributes).
    IF v_logout_style NOT IN ('STYLE1', 'STYLE2', 'STYLE3', 'STYLE4') THEN
        v_logout_style := 'STYLE1';
    END IF;

    ----------------------------------------------------------------
    -- Resolve First Name / Last Name / Email. Each attribute is
    -- resolved independently - if written as e.g.
    -- "SUPER_ADMIN.SUAD_EMAIL.SUAD_FIRST_NAME" it runs its own lookup
    -- against that table, matched by SUAD_EMAIL against the current
    -- APP_USER. Anything NOT in that format is used as-is (legacy
    -- literal text / &ITEM. substitution string).
    --
    -- Email additionally falls back to APP_USER itself when it's a DB
    -- lookup that finds no row - a deliberately blank literal Email
    -- attribute still renders blank either way.
    ----------------------------------------------------------------
    v_email_is_db := f_parse_table_match_value(v_email_attr, v_e_table, v_e_match, v_e_value);

    IF v_email_is_db THEN
        v_user_email := f_lookup_value(v_e_table, v_e_match, v_e_value, v_app_user);
        IF v_user_email IS NULL THEN
            v_user_email := v_app_user;
        END IF;
    ELSE
        v_user_email := v_email_attr;
    END IF;

    v_user_first_name := f_resolve_text(v_first_name_attr, v_app_user);
    v_user_last_name  := f_resolve_text(v_last_name_attr, v_app_user);

    v_user_name := TRIM(NVL(v_user_first_name, '') || ' ' || NVL(v_user_last_name, ''));

    ----------------------------------------------------------------
    -- Resolve the profile image. Image Source and Image Mime Type
    -- each carry their OWN table/match column:
    --   Image Source     -> SUPER_ADMIN.SUAD_EMAIL.SUAD_PROFILE_BLOB
    --   Image Mime Type  -> SUPER_ADMIN.SUAD_EMAIL.SUAD_PROFILE_MIME
    --
    -- If Image Source does NOT match that format, it's used as a
    -- literal image URL (legacy behavior). If it DOES match, the BLOB
    -- is Base64-encoded via the built-in
    -- APEX_WEB_SERVICE.BLOB2CLOBBASE64 and embedded as a "data:" URI.
    -- Above c_max_image_bytes, it falls back to initials instead.
    ----------------------------------------------------------------
    v_image_is_db := f_parse_table_match_value(v_image_source_attr, v_img_table, v_img_match, v_img_value);

    IF v_image_is_db THEN
        v_image_blob := f_lookup_blob(v_img_table, v_img_match, v_img_value, v_app_user);

        IF v_image_blob IS NOT NULL AND DBMS_LOB.GETLENGTH(v_image_blob) > 0 THEN
            IF DBMS_LOB.GETLENGTH(v_image_blob) > c_max_image_bytes THEN
                apex_debug.warn(
                    p_message => 'SH_USER_MENU: profile image for %s is %s bytes (max %s) - falling back to initials.',
                    p0        => v_img_table,
                    p1        => TO_CHAR(DBMS_LOB.GETLENGTH(v_image_blob)),
                    p2        => TO_CHAR(c_max_image_bytes)
                );
            ELSE
                IF f_parse_table_match_value(v_image_mime_attr, v_mime_table, v_mime_match, v_mime_value) THEN
                    v_image_mime := f_lookup_value(v_mime_table, v_mime_match, v_mime_value, v_app_user);
                END IF;

                IF v_image_mime IS NULL THEN
                    apex_debug.warn(
                        p_message => 'SH_USER_MENU: no Image Mime Type resolved for %s - defaulting to image/png',
                        p0        => v_img_table
                    );
                    v_image_mime := 'image/png';
                END IF;

                v_image_base64 := APEX_WEB_SERVICE.BLOB2CLOBBASE64(p_blob => v_image_blob);

                -- MIME type is small (single DB column, not user
                -- input) - safe and cheap to escape normally. The
                -- Base64 payload is NOT escaped: apex_escape.html_attribute
                -- only accepts VARCHAR2 (32767-char ceiling) and a real
                -- photo easily encodes past that - escaping would be a
                -- no-op anyway, since Base64 never contains & < > " '.
                v_image_data_uri := 'data:' || apex_escape.html_attribute(v_image_mime) ||
                    ';base64,' || v_image_base64;
            END IF;
        END IF;
    ELSE
        -- Legacy mode: literal URL / &ITEM. substitution string.
        v_image_src := v_image_source_attr;
    END IF;

    ----------------------------------------------------------------
    -- Determine unique DOM ids for this region instance
    ----------------------------------------------------------------
    v_static_id  := NVL(p_region.static_id, 'r' || p_region.id);
    v_wrapper_id := 'sh-um-' || v_static_id;
    v_panel_id   := 'sh-um-panel-' || v_static_id;

    v_is_outside_logout := (v_show_logout = 'Y' AND v_logout_position = 'OUTSIDE');
    v_is_inside_logout  := (v_show_logout = 'Y' AND v_logout_position = 'INSIDE');

    -- If no Logout Target is configured, fall back to APEX's own
    -- built-in "LOGOUT" special request, which ends the session and
    -- redirects to the login page regardless of app-specific setup.
    IF v_logout_link_attr IS NULL THEN
        v_logout_link_attr := apex_page.get_url(p_request => 'LOGOUT');
    END IF;

    ----------------------------------------------------------------
    -- Load dropdown entries from the developer-supplied SQL query. If
    -- none is supplied, fall back to the plugin's built-in default
    -- menu. Expected result: 4 columns in this order (icon, text,
    -- link, menu_type) - icon accepts "icon_value" or
    -- "icon_value|#hexcolor", see f_render_icon_span above. Wrapped in
    -- its own block so a broken query never breaks the page.
    ----------------------------------------------------------------
    IF v_show_dropdown = 'Y' THEN
        IF v_dropdown_query IS NULL THEN
            v_dropdown_query :=
                q'[SELECT 'fa-gear'                          AS icon,
                          'Settings'                         AS dropdown_text,
                          'f?p=&APP_ID.:900:&SESSION.::::'   AS link,
                          'MAIN'                             AS menu_type
                   FROM dual
                   UNION ALL
                   SELECT 'fa-user-circle',
                          'Campus Administrator',
                          'f?p=&APP_ID.:20:&SESSION.::::',
                          'MAIN'
                   FROM dual]';
        END IF;

        BEGIN
            EXECUTE IMMEDIATE v_dropdown_query
                BULK COLLECT INTO v_icons, v_text_tab, v_link_tab, v_type_tab;
        EXCEPTION
            WHEN OTHERS THEN
                apex_debug.error(
                    p_message => 'SH_USER_MENU: dropdown query failed - %s',
                    p0        => SQLERRM
                );
                v_icons    := t_vc_tab();
                v_text_tab := t_vc_tab();
                v_link_tab := t_vc_tab();
                v_type_tab := t_vc_tab();
        END;
    END IF;

    ----------------------------------------------------------------
    -- Build dropdown item rows
    ----------------------------------------------------------------
    v_items_html := '';

    FOR i IN 1 .. v_icons.COUNT LOOP
        v_items_html := v_items_html ||
            '<div class="sh-um-item' ||
            CASE WHEN UPPER(v_type_tab(i)) = 'SUB' THEN ' sh-um-item--sub' ELSE NULL END ||
            '" data-link="' || apex_escape.html_attribute(
                apex_util.prepare_url(p_url => v_link_tab(i))
            ) || '" ' ||
            'role="menuitem" tabindex="-1">' ||
            '<span class="sh-um-item-icon">' || f_render_icon_span(v_icons(i)) || '</span>' ||
            '<span class="sh-um-item-text">' || apex_escape.html(v_text_tab(i)) || '</span>' ||
            '</div>';
    END LOOP;

    IF v_is_inside_logout THEN
        v_items_html := v_items_html ||
            '<div class="sh-um-separator"></div>' ||
            '<div class="sh-um-item sh-um-item--logout" data-link="' ||
            apex_escape.html_attribute(
                apex_util.prepare_url(p_url => v_logout_link_attr)
            ) || '" role="menuitem" tabindex="-1">' ||
            '<span class="sh-um-item-icon">' || f_render_icon_span(v_logout_icon_raw) || '</span>' ||
            '<span class="sh-um-item-text">' || f_txt('Abmelden', 'Sign Out') || '</span>' ||
            '</div>';
    END IF;

    ----------------------------------------------------------------
    -- Build the trigger (avatar + name + email + status + chevron)
    ----------------------------------------------------------------
    v_html := '<div id="' || v_wrapper_id || '" class="sh-um-wrapper" ' ||
        'data-um-align="RIGHT" ' ||
        'style="--sh-um-panel-bg:' || f_color(v_dropdown_bg_attr, '#FFFFFF') || ';' ||
               '--sh-um-panel-hover:' || f_color(v_dropdown_hover_attr, '#F3F4F6') || ';' ||
               '--sh-um-panel-text:' || f_color(v_dropdown_text_attr, '#111827') || ';">';

    v_html := v_html || '<div class="sh-um-trigger" tabindex="0" role="button" ' ||
        'aria-haspopup="true" aria-expanded="false" aria-label="' ||
        apex_escape.html_attribute(f_txt('Benutzermenü', 'User menu')) || '">';

    -- Avatar
    IF v_show_image = 'Y' THEN
        v_html := v_html ||
            '<span class="sh-um-avatar sh-um-avatar--' || LOWER(v_image_shape) || '" ' ||
            'style="width:' || f_number(v_image_size_attr, 28) || 'px;height:' || f_number(v_image_size_attr, 28) || 'px;' ||
            CASE WHEN v_image_border_color IS NOT NULL
                 THEN 'border-color:' || f_color(v_image_border_color, '#E5E7EB') || ';'
                 ELSE NULL END || '">';

        IF v_image_data_uri IS NOT NULL THEN
            -- Base64 data URI - embedded as-is, see the comment where
            -- v_image_data_uri is built above for why it can't go
            -- through apex_escape.html_attribute.
            v_html := v_html || '<img src="' || v_image_data_uri ||
                '" alt="" class="sh-um-avatar-img">';
        ELSIF v_image_src IS NOT NULL THEN
            v_html := v_html || '<img src="' ||
                apex_escape.html_attribute(v_image_src) ||
                '" alt="" class="sh-um-avatar-img">';
        ELSE
            v_html := v_html || '<span class="sh-um-avatar-initials">' ||
                apex_escape.html(f_initials(v_user_name)) || '</span>';
        END IF;

        IF v_show_status = 'Y' THEN
            v_html := v_html || '<span class="sh-um-status-dot" style="background:' ||
                f_color(v_status_color_attr, '#22C55E') || ';"></span>';
        END IF;

        v_html := v_html || '</span>';
    END IF;

    -- Name / Email
    IF v_user_name IS NOT NULL OR v_user_email IS NOT NULL THEN
        v_html := v_html || '<span class="sh-um-text">';
        IF v_user_name IS NOT NULL THEN
            v_html := v_html || '<span class="sh-um-name">' || apex_escape.html(v_user_name) || '</span>';
        END IF;
        IF v_user_email IS NOT NULL THEN
            v_html := v_html || '<span class="sh-um-email">' || apex_escape.html(v_user_email) || '</span>';
        END IF;
        v_html := v_html || '</span>';
    END IF;

    -- Chevron
    IF v_show_dropdown = 'Y' AND v_show_chevron = 'Y' THEN
        v_html := v_html || '<span class="sh-um-chevron" aria-hidden="true"></span>';
    END IF;

    v_html := v_html || '</div>'; -- .sh-um-trigger

    -- Outside logout button. Class carries the selected Logout Style
    -- (sh-um-logout-outside--style1..4) so CSS alone controls the
    -- visual variant - no JS changes required. Style3/Style4 also get
    -- a text label next to the icon.
    IF v_is_outside_logout THEN
        v_html := v_html || '<a class="sh-um-logout-outside sh-um-logout-outside--' ||
            LOWER(v_logout_style) || '" href="' ||
            apex_escape.html_attribute(
                apex_util.prepare_url(p_url => v_logout_link_attr)
            ) || '" aria-label="' || apex_escape.html_attribute(f_txt('Abmelden', 'Sign Out')) ||
            '" title="' || apex_escape.html_attribute(f_txt('Abmelden', 'Sign Out')) || '">' ||
            f_render_icon_span(v_logout_icon_raw);

        IF v_logout_style IN ('STYLE3', 'STYLE4') THEN
            v_html := v_html || '<span class="sh-um-logout-outside-text">' ||
                apex_escape.html(f_txt('Abmelden', 'Sign Out')) || '</span>';
        END IF;

        v_html := v_html || '</a>';
    END IF;

    v_html := v_html || '</div>'; -- .sh-um-wrapper

    ----------------------------------------------------------------
    -- Dropdown panel markup (hidden by default, moved to <body> by JS)
    ----------------------------------------------------------------
    IF v_show_dropdown = 'Y' THEN
        v_html := v_html ||
            '<div id="' || v_panel_id || '" class="sh-um-panel" role="menu" ' ||
            'aria-hidden="true" ' ||
            'style="--sh-um-panel-bg:' || f_color(v_dropdown_bg_attr, '#FFFFFF') || ';' ||
                   '--sh-um-panel-hover:' || f_color(v_dropdown_hover_attr, '#F3F4F6') || ';' ||
                   '--sh-um-panel-text:' || f_color(v_dropdown_text_attr, '#111827') || ';">' ||
            '<div class="sh-um-panel-items">' || v_items_html || '</div>' ||
            '</div>';
    END IF;

    ----------------------------------------------------------------
    -- Output + JS init call
    ----------------------------------------------------------------
    p_print_clob(v_html);

    -- The Base64 image data came from a temporary CLOB
    -- (APEX_WEB_SERVICE.BLOB2CLOBBASE64) and has now been fully
    -- copied into v_html by the concatenation above and flushed out -
    -- free it so the session doesn't accumulate temporary LOB space
    -- across page views.
    IF v_image_base64 IS NOT NULL AND DBMS_LOB.ISTEMPORARY(v_image_base64) = 1 THEN
        DBMS_LOB.FREETEMPORARY(v_image_base64);
    END IF;

    IF v_show_dropdown = 'Y' THEN
        apex_javascript.add_onload_code(
            p_code => 'SH_USER_MENU.init(' || apex_javascript.add_value(v_wrapper_id) || ');'
        );
    END IF;

    RETURN v_result;
END render;