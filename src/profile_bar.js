/* ==========================================================================
   S&H Software Solutions - User Menu Region Plugin
   Namespace: SH_USER_MENU
   ========================================================================== */
 
var SH_USER_MENU = (function () {
    "use strict";
 
    // Track initialized wrapper ids so init() can safely be called more
    // than once for the same region (e.g. after an Ajax region refresh).
    var initialized = {};
 
    function getPanel(wrapperId) {
        var panelId = "sh-um-panel-" + wrapperId.replace(/^sh-um-/, "");
        return document.getElementById(panelId);
    }
 
    function positionPanel(trigger, panel, align) {
        var rect = trigger.getBoundingClientRect();
        var gap = 6;
 
        panel.style.top = (rect.bottom + gap) + "px";
 
        if (align === "LEFT") {
            panel.style.left = rect.left + "px";
            panel.style.right = "auto";
        } else {
            panel.style.left = "auto";
            panel.style.right = (window.innerWidth - rect.right) + "px";
        }
    }
 
    function init(wrapperId) {
        var wrapper = document.getElementById(wrapperId);
        if (!wrapper) {
            return;
        }
 
        var trigger = wrapper.querySelector(".sh-um-trigger");
        var panel = getPanel(wrapperId);
 
        if (!trigger || !panel) {
            return;
        }
 
        // Portal pattern: move the panel out of the navbar so an
        // ancestor's overflow:hidden can never clip it.
        if (panel.parentNode !== document.body) {
            document.body.appendChild(panel);
        }
 
        // Avoid double-binding listeners if init() runs again for the
        // same wrapper (e.g. after a partial page refresh).
        if (initialized[wrapperId]) {
            return;
        }
        initialized[wrapperId] = true;
 
        var align = wrapper.getAttribute("data-um-align") || "RIGHT";
        var items = Array.prototype.slice.call(
            panel.querySelectorAll(".sh-um-item")
        );
 
// Keep in sync with the CSS "sh-um-panel-out" animation-duration.
var CLOSE_ANIMATION_MS = 300;
var closeFinalizeTimer = null;

// Only clears the pending timer - does NOT touch the "is-closing"
// class. (Removing the class here was the bug: closePanel() called
// this right after adding "is-closing", instantly stripping it back
// off before the browser ever painted a frame - so the close
// animation never had a chance to run.)
function clearCloseTimer() {
    if (closeFinalizeTimer) {
        window.clearTimeout(closeFinalizeTimer);
        closeFinalizeTimer = null;
    }
}

function openPanel() {
    // Reopening mid-close: cancel the pending finalize timer AND
    // explicitly drop "is-closing" here (this is the one place that
    // should remove it, since we're about to show the panel fresh).
    clearCloseTimer();
    panel.classList.remove("is-closing");
    positionPanel(trigger, panel, align);
    panel.classList.add("is-open");
    panel.setAttribute("aria-hidden", "false");
    trigger.setAttribute("aria-expanded", "true");
    wrapper.classList.add("is-active");
}

function closePanel(returnFocus) {
    if (!isOpen()) {
        return;
    }

    // Only clear a stray timer here - never touch the class, since
    // we're adding "is-closing" below and need it to survive.
    clearCloseTimer();

    panel.classList.remove("is-open");
    panel.classList.add("is-closing");
    panel.setAttribute("aria-hidden", "true");
    trigger.setAttribute("aria-expanded", "false");
    wrapper.classList.remove("is-active");

    closeFinalizeTimer = window.setTimeout(function () {
        panel.classList.remove("is-closing");
        closeFinalizeTimer = null;
        if (returnFocus) {
            trigger.focus();
        }
    }, CLOSE_ANIMATION_MS);
}

function isOpen() {
    return panel.classList.contains("is-open");
}
 
        function togglePanel(event) {
            event.stopPropagation();
            if (isOpen()) {
                closePanel(false);
            } else {
                openPanel();
            }
        }
 
        function activateItem(item) {
            var link = item.getAttribute("data-link");
            closePanel(false);
            if (link) {
                window.location.href = link;
            }
        }
 
        function focusItem(index) {
            if (items.length === 0) {
                return;
            }
            var target = ((index % items.length) + items.length) % items.length;
            items[target].focus();
        }
 
        // -- Trigger interaction ------------------------------------------------
        trigger.addEventListener("click", togglePanel);
 
        trigger.addEventListener("keydown", function (event) {
            if (event.key === "Enter" || event.key === " ") {
                event.preventDefault();
                togglePanel(event);
                if (isOpen()) {
                    focusItem(0);
                }
            } else if (event.key === "ArrowDown" && !isOpen()) {
                event.preventDefault();
                openPanel();
                focusItem(0);
            } else if (event.key === "Escape") {
                closePanel(false);
            }
        });
 
        // -- Menu item interaction ------------------------------------------------
        items.forEach(function (item, index) {
            item.addEventListener("click", function () {
                activateItem(item);
            });
 
            item.addEventListener("keydown", function (event) {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    activateItem(item);
                } else if (event.key === "ArrowDown") {
                    event.preventDefault();
                    focusItem(index + 1);
                } else if (event.key === "ArrowUp") {
                    event.preventDefault();
                    focusItem(index - 1);
                } else if (event.key === "Escape") {
                    closePanel(true);
                } else if (event.key === "Tab") {
                    closePanel(false);
                }
            });
        });
 
        // -- Global close handlers ------------------------------------------------
        document.addEventListener("click", function (event) {
            if (!isOpen()) {
                return;
            }
            if (!panel.contains(event.target) && !trigger.contains(event.target)) {
                closePanel(false);
            }
        });
 
        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape" && isOpen()) {
                closePanel(true);
            }
        });
 
        window.addEventListener("resize", function () {
            if (isOpen()) {
                positionPanel(trigger, panel, align);
            }
        });
 
        window.addEventListener("scroll", function () {
            if (isOpen()) {
                positionPanel(trigger, panel, align);
            }
        }, true);
    }
 
    return {
        init: init
    };
})();